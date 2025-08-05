defmodule TagzUp.Business.BusinessProfile do
  use Ash.Resource,
    domain: TagzUp.Business,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "business_profiles"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :user_id, :uuid, allow_nil?: false, public?: true
    attribute :company_name, :string, allow_nil?: false, public?: true
    attribute :industry, :string, public?: true
    attribute :website_url, :string, public?: true
    attribute :logo_url, :string, public?: true
    attribute :description, :string, public?: true
    attribute :location, :string, public?: true
    attribute :company_size, :atom do
      constraints one_of: [:startup, :small, :medium, :large, :enterprise]
      public? true
    end
    attribute :verification_status, :atom do
      constraints one_of: [:pending, :verified, :rejected]
      default :pending
      public? true
    end
    attribute :total_campaigns, :integer, default: 0, public?: true
    attribute :total_spent, :decimal, default: 0, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, TagzUp.Accounts.User do
      attribute_writable? true
    end
  end

  actions do
    defaults [:read]
    default_accept [
      :company_name, :industry, :website_url, :logo_url, :description,
      :location, :company_size
    ]

    create :create do
      accept [
        :user_id, :company_name, :industry, :website_url, :logo_url,
        :description, :location, :company_size
      ]
      primary? true
    end

    update :update do
      accept [
        :company_name, :industry, :website_url, :logo_url, :description,
        :location, :company_size
      ]
      primary? true
    end

    update :verify do
      accept [:verification_status]
    end

    update :update_stats do
      accept [:total_campaigns, :total_spent]
    end

    read :verified do
      filter expr(verification_status == :verified)
    end

    read :by_industry do
      argument :industry, :string, allow_nil?: false
      filter expr(industry == ^arg(:industry))
    end
  end

  code_interface do
    define :create
    define :update
    define :verify
    define :update_stats
    define :verified
    define :by_industry, args: [:industry]
  end
end