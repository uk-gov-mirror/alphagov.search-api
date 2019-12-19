# MultiSchemaMigrator migrates the schema for indexes in parallel
class MultiSchemaMigrator
  attr_reader :failed

  def initialize(index_names, cluster: Clusters.default_cluster, wait_between_task_list_check: 0.01)
    @index_names = index_names
    @cluster = cluster
    @wait_between_task_list_check = wait_between_task_list_check
    @failed = []
  end

  def reindex_all
    migrators = []
    task_ids = []
    # Start up migrations
    index_names.map do |index_name|
      migrator = SchemaMigrator.new(index_name, cluster: cluster)
      migrators << migrator
      migrator.index_group.current.with_lock do
        migration = migrator.reindex
        task_ids << migration.fetch("task")
      end
    end

    # Wait until all migrations complete
    while (running_tasks & task_ids).any?
      puts "Waiting for tasks #{(running_tasks & task_ids).to_sentence}"
      sleep @wait_between_task_list_check
    end

    # Finish migrations
    migrators.each do |migrator|
      if migrator.changed?
        puts "Difference during reindex for: #{migrator.index_name}"
        puts migrator.comparison.inspect
        failed << migrator
      else
        puts "Switching #{migrator.index_name} to new index"
        migrator.switch_to_new_index
      end
    end

    puts "All schema migrations complete!"
  end

private

  attr_reader :index_names, :cluster
  attr_writer :failed

  # this is awful but is caused by the return format of the tasks lists
  def running_tasks
    tasks = Services.elasticsearch(cluster: cluster).tasks.list(actions: "*reindex")
    nodes = tasks["nodes"] || {}
    node_details = nodes.values || []
    tasks = node_details.flat_map { |a| a["tasks"] }
    tasks.flat_map(&:keys)
  end
end
