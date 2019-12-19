class SchemaMigrator
  attr_accessor :index_name

  def initialize(index_name, cluster: Clusters.default_cluster, wait_between_task_list_check: 5, io: STDOUT)
    @index_name = index_name
    @cluster = cluster
    @wait_between_task_list_check = wait_between_task_list_check
    @io = io
  end

  def reindex
    # TODO: Could we make this faster?
    # https://www.elastic.co/guide/en/elasticsearch/reference/6.7/docs-reindex.html#_url_parameters_3
    Services.elasticsearch(hosts: "#{cluster.uri}?slices=auto", timeout: 60).reindex(
      wait_for_completion: false,
      body: {
        source: {
          index: index_group.current.real_name,
        },
        dest: {
          index: index.real_name,
          version_type: "external",
        },
      },
      refresh: true,
    )
  end

  def changed?
    comparison[:changed] != 0 ||
      comparison[:removed_items] != 0 ||
      comparison[:added_items] != 0
  end

  def switch_to_new_index
    index_group.switch_to(index)
  end

  def comparison
    @comparison ||= Indexer::Comparer.new(index_group.current.real_name, index.real_name, cluster: cluster, io: io).run
  end

  def index_group
    @index_group ||= SearchConfig.instance(cluster).search_server.index_group(@index_name)
  end

private

  attr_reader :io, :cluster

  def index
    @index ||= index_group.create_index
  end
end
