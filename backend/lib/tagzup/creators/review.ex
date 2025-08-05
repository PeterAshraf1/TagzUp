defmodule TagzUp.Creators.Review do
  use Ash.Resource,
    domain: TagzUp.Creators,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "reviews"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :influencer_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :business_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :booking_id, :uuid, allow_nil?: false, public?: true
    attribute :rating, :integer do
      constraints min: 1, max: 5
      allow_nil? false
      public? true
    end
    attribute :comment, :string, public?: true
    attribute :is_public, :boolean, default: true, public?: true
    
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
    default_accept [:rating, :comment, :is_public]

    create :create do
      accept [:influencer_profile_id, :business_profile_id, :booking_id, :rating, :comment, :is_public]
      primary? true
    end

    update :update do
      accept [:rating, :comment, :is_public]
      primary? true
    end

    read :public_reviews do
      filter expr(is_public == true)
    end

    read :by_rating do
      argument :min_rating, :integer
      filter expr(rating >= ^arg(:min_rating))
    end
  end

  code_interface do
    define :create
    define :update
    define :public_reviews
    define :by_rating, args: [:min_rating]
  end
end