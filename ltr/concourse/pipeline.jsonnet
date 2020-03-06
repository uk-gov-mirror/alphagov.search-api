# deploy with:
# $ jsonnet pipeline.jsonnet > pipeline.json
# $ fly set-pipeline -t cd-govuk-tools -p search-learn-to-rank -c pipeline.json

local resource_type(name, repository, tag='latest') = {
  name: name,
  type: 'docker-image',
  source: {
    repository: repository,
    tag: tag,
  },
};

local s3_state_resource(environment, name) = {
  name: environment + '-' + name,
  type: 's3-iam',
  source: {
    bucket: '((readonly_private_bucket_name))',
    region_name: 'eu-west-2',
    regexp: 'search-learn-to-rank/' +  environment + '-' + name + '-([0-9]*).txt',
  },
};

local secret(environment, name) = '((' + environment + '-' + name + '))';

local task(task, notify_on_failure, config) = {
  config: config + {
    platform: 'linux',
    image_resource: {
      type: 'docker-image',
      source: {
        repository: 'python',
        tag: '3.7',
      },
    },
    run: {
      path: 'bash',
      args: ['search-api-git/ltr/concourse/task.sh', task],
    },
  },
  [if notify_on_failure then 'on_failure']: {
    put: 'govuk-searchandnav-slack',
    params: {
      channel: '#govuk-searchandnav',
      username: 'Daily LTR',
      icon_emoji: ':concourse:',
      silent: true,
      text: |||
        :kaboom:
        The $BUILD_JOB_NAME Concourse job has failed
        Failed build: http://cd.gds-reliability.engineering/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME/jobs/$BUILD_JOB_NAME/builds/$BUILD_NAME
      |||,
    },
  },
};

local fetch_job(environment, name='fetch', notify_on_failure=false) = {
  name: environment + '-' + name,
  plan: [
    { get: 'at-10pm', trigger: true },
    { get: 'search-api-git' },
    { task: 'Fetch' } + task('fetch', notify_on_failure, {
      inputs: [ { name: 'search-api-git' } ],
      outputs: [ { name: 'out' } ],
      params: {
        GOVUK_ENVIRONMENT: environment,
        SEARCH_API_BEARER_TOKEN: secret(environment, 'search-api-bearer-token'),
        OUTPUT_FILE_NAME: 'training-data',
      },
    }),
    {
      put: environment + '-training-data',
      params: { file: 'out/' + environment + '-training-data-*.txt' },
    },
  ],
};

local train_job(environment, name='train', notify_on_failure=false, image_tag=null, prior_job=true) = {
  name: environment + '-' + name,
  plan:
    (if prior_job then [ { get: environment + '-training-data', passed: [ environment + '-fetch' ], trigger: true } ] else []) + [
    { get: 'search-api-git' },
    { task: 'Train' } + task('train', notify_on_failure, {
      inputs:
        (if prior_job then [ { name: environment + '-training-data' } ] else []) +
        [ { name: 'search-api-git' } ],
      outputs: [ { name: 'out' } ],
      params: {
        GOVUK_ENVIRONMENT: environment,
        IMAGE: secret(environment, 'ecr-repository'),
        ROLE_ARN: secret(environment, 'role-arn'),
        [if prior_job then 'INPUT_FILE_NAME']: 'training-data',
        OUTPUT_FILE_NAME: 'model',
        [if image_tag != null then 'IMAGE_TAG']: image_tag,
      },
    }),
    {
      put: environment + '-model',
      params: { file: 'out/' + environment + '-model-*.txt' },
    },
  ],
};

local deploy_job(environment, name='deploy', notify_on_failure=false, model_tag=null, prior_job=true) = {
  name: environment + '-' + name,
  plan:
    (if prior_job then [ { get: environment + '-model', passed: [ environment + '-train' ], trigger: true } ] else []) + [
    { get: 'search-api-git' },
    { task: 'Deploy' } + task('deploy', notify_on_failure, {
      inputs:
        (if prior_job then [ { name: environment + '-model' } ] else []) +
        [ { name: 'search-api-git' } ],
      params: {
        GOVUK_ENVIRONMENT: environment,
        ROLE_ARN: secret(environment, 'role-arn'),
        [if prior_job then 'INPUT_FILE_NAME']: 'model',
        [if model_tag != null then 'MODEL_TAG']: model_tag,
      },
    }),
  ],
};

{
  resource_types: [
    resource_type('cron-resource', 'cftoolsmiths/cron-resource'),
    resource_type('s3-iam', 'governmentpaas/s3-resource', '97e441efbfb06ac7fb09786fd74c64b05f9cc907'),
    resource_type('slack-notification', 'cfcommunity/slack-notification-resource'),
  ],

  resources: [
    {
      name: 'at-10pm',
      type: 'cron-resource',
      source: {
        expression: '00 22 * * *',
        location: 'Europe/London',
      },
    },
    {
      name: 'search-api-git',
      type: 'git',
      source: {
        uri: 'https://github.com/alphagov/search-api.git',
      },
    },
    {
      name: 'govuk-searchandnav-slack',
      type: 'slack-notification',
      source: {
        url: '((slack-webhook-url))',
      },
    },
    s3_state_resource('integration', 'training-data'),
    s3_state_resource('staging', 'training-data'),
    s3_state_resource('production', 'training-data'),
    s3_state_resource('integration', 'model'),
    s3_state_resource('staging', 'model'),
    s3_state_resource('production', 'model'),
  ],

  jobs: [
    fetch_job('integration'),
    fetch_job('staging'),
    fetch_job('production', notify_on_failure=true),

    train_job('integration'),
    train_job('staging'),
    train_job('production', notify_on_failure=true),

    deploy_job('integration'),
    deploy_job('staging'),
    deploy_job('production', notify_on_failure=true),

    deploy_job('integration', name='deploy-model-hippo',    model_tag='hippo',    prior_job=false),
    deploy_job('staging',     name='deploy-model-hippo',    model_tag='hippo',    prior_job=false),
    deploy_job('production',  name='deploy-model-hippo',    model_tag='hippo',    prior_job=false),
    deploy_job('integration', name='deploy-model-elephant', model_tag='elephant', prior_job=false),
    deploy_job('staging',     name='deploy-model-elephant', model_tag='elephant', prior_job=false),
    deploy_job('production',  name='deploy-model-elephant', model_tag='elephant', prior_job=false),
  ],
}
