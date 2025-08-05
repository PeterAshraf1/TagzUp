defmodule TagzUp.Bookings.Dispute do
  use Ash.Resource,
    domain: TagzUp.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "disputes"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :booking_id, :uuid, allow_nil?: false, public?: true
    attribute :raised_by_user_id, :uuid, allow_nil?: false, public?: true
    attribute :reason, :atom do
      constraints one_of: [
        :content_not_delivered, :poor_quality, :late_delivery,
        :content_removed_early, :payment_issue, :other
      ]
      allow_nil? false
      public? true
    end
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :evidence_urls, {:array, :string}, default: [], public?: true
    attribute :status, :atom do
      constraints one_of: [:open, :investigating, :resolved, :closed]
      default :open
      public? true
    end
    attribute :resolution, :string, public?: true
    attribute :resolved_by_user_id, :uuid, public?: true
    attribute :resolved_at, :utc_datetime, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :booking, TagzUp.Bookings.Booking do
      attribute_writable? true
    end
  end

  actions do
    defaults [:read]
    default_accept [:reason, :description, :evidence_urls]

    create :create do
      accept [:booking_id, :raised_by_user_id, :reason, :description, :evidence_urls]
      primary? true
    end

    update :update do
      accept [:description, :evidence_urls]
      primary? true
    end

    update :resolve do
      accept [:status, :resolution, :resolved_by_user_id, :resolved_at]
    end

    read :by_status do
      argument :status, :atom, allow_nil?: false
      filter expr(status == ^arg(:status))
    end

    read :open_disputes do
      filter expr(status in [:open, :investigating])
    end
  end

  code_interface do
    define :create
    define :update
    define :resolve
    define :by_status, args: [:status]
    define :open_disputes
  end
end