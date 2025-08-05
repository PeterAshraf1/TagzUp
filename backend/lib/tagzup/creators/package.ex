defmodule TagzUp.Creators.Package do
  use Ash.Resource,
    domain: TagzUp.Creators,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "packages"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :influencer_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :title, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :platforms, {:array, :atom}, allow_nil?: false, public?: true
    attribute :deliverables, {:array, :string}, allow_nil?: false, public?: true
    attribute :price, :decimal, allow_nil?: false, public?: true
    attribute :currency, :string, default: "EGP", public?: true
    attribute :delivery_time_days, :integer, allow_nil?: false, public?: true
    attribute :revisions_included, :integer, default: 1, public?: true
    attribute :post_duration_hours, :integer, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    attribute :requirements, :string, public?: true
    attribute :sample_work_urls, {:array, :string}, default: [], public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :influencer_profile, TagzUp.Creators.InfluencerProfile do
      attribute_writable? true
    end
  end

  actions do
    defaults [:read]
    default_accept [
      :title, :description, :platforms, :deliverables, :price, :currency,
      :delivery_time_days, :revisions_included, :post_duration_hours,
      :requirements, :sample_work_urls, :is_active
    ]

    create :create do
      accept [
        :influencer_profile_id, :title, :description, :platforms, :deliverables,
        :price, :currency, :delivery_time_days, :revisions_included,
        :post_duration_hours, :requirements, :sample_work_urls
      ]
      primary? true
    end

    update :update do
      accept [
        :title, :description, :platforms, :deliverables, :price, :currency,
        :delivery_time_days, :revisions_included, :post_duration_hours,
        :requirements, :sample_work_urls, :is_active
      ]
      primary? true
    end

    read :active do
      filter expr(is_active == true)
    end

    read :by_platform do
      argument :platform, :atom, allow_nil?: false
      filter expr(^arg(:platform) in platforms)
    end

    read :by_price_range do
      argument :min_price, :decimal
      argument :max_price, :decimal
      
      filter expr(
        if not is_nil(^arg(:min_price)) do
          price >= ^arg(:min_price)
        else
          true
        end and
        if not is_nil(^arg(:max_price)) do
          price <= ^arg(:max_price)
        else
          true
        end
      )
    end
  end

  code_interface do
    define :create
    define :update
    define :active
    define :by_platform, args: [:platform]
    define :by_price_range, args: [:min_price, :max_price]
  end
end