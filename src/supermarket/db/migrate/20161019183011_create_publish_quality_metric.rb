class CreatePublishQualityMetric < ActiveRecord::Migration
  def change
    publish_qm = QualityMetric.create!(name: 'Publish', admin_only: true)
  end
end
