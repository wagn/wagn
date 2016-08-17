add_to_basket(:tasks,
  [
    :upldate_file_storage_locations,
    {
      execute_policy: -> {
        Card::CarrierWave::FileCardUploader.update_all_storage_locations
      },
      stats_policy: -> {
        [ "cards with attachment",
          { count: Card.search(type_id: ["in", FileID, ImageID],
                               return: :count),
            link_text: "update storage locations",
            task: "update_file_storage_locations" }
        ]
      }
    }
  ]
)
