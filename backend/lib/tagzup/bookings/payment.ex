defmodule TagzUp.Bookings.Payment do
  use Ash.Resource,
    domain: TagzUp.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "payments"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :booking_id, :uuid, allow_nil?: false, public?: true
    attribute :stripe_payment_intent_id, :string, public?: true
    attribute :amount, :decimal, allow_nil?: false, public?: true
    attribute :currency, :string, default: "EGP", public?: true
    attribute :status, :atom do
      constraints one_of: [:pending, :processing, :succeeded, :failed, :cancelled, :refunded]
      default :pending
      public? true
    end
    attribute :payment_method, :string, public?: true
    attribute :failure_reason, :string, public?: true
    attribute :metadata, :map, public?: true
    
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

    create :create do
      accept [:booking_id, :amount, :currency, :payment_method, :metadata]
      primary? true
    end

    update :update_status do
      accept [:status, :stripe_payment_intent_id, :failure_reason, :metadata]
    end

    read :by_status do
      argument :status, :atom, allow_nil?: false
      filter expr(status == ^arg(:status))
    end

    read :successful do
      filter expr(status == :succeeded)
    end
  end

  code_interface do
    define :create
    define :update_status
    define :by_status, args: [:status]
    define :successful
  end
end