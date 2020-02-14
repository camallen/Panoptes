# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if defined?(FactoryBot)
    FactoryBot.create :full_project
end

Panoptes.flipper.enable(:subject_uploading)
Panoptes.flipper.enable(:classification_lifecycle_in_background)
Panoptes.flipper.enable(:classification_counters)
Panoptes.flipper.enable(:subject_set_statuses_create_worker)
Panoptes.flipper.enable(:subject_workflow_status_create_worker)
Panoptes.flipper.enable(:remove_orphan_subjects)
Panoptes.flipper.enable(:selector_sync_error_reload)

Panoptes.flipper.disable(:dump_worker_exports)
Panoptes.flipper.disable(:cached_serializer)
Panoptes.flipper.disable(:designator)
Panoptes.flipper.disable(:cellect)
Panoptes.flipper.disable(:export_emails)
Panoptes.flipper.disable(:disable_lifecycle_worker)
Panoptes.flipper.disable(:skip_subject_selection_context)