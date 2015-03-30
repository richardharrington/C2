module Ncr
  class WorkOrderSerializer < ActiveModel::Serializer
    # make sure to keep docs/api.md up-to-date

    attributes(
      :amount,
      :building_number,
      :code,
      :description,
      :emergency,
      :expense_type,
      :id,
      :name,
      :not_to_exceed,
      :office,
      :rwa_number,
      :vendor
    )

    has_one :proposal
  end
end
