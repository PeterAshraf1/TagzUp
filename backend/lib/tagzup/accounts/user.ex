defmodule TagzUp.Accounts.User do
  use Ash.Resource,
    domain: TagzUp.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  postgres do
    table "users"
    repo TagzUp.Repo
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
      end
    end

    tokens do
      enabled? true
      token_resource TagzUp.Accounts.Token
      require_token_presence_for_authentication? true
      signing_secret fn _, _ ->
        Application.fetch_env(:ash_authentication, AshAuthentication.Jwt)
        |> case do
          {:ok, config} -> {:ok, config[:signing_secret]}
          :error -> :error
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :phone, :string, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :user_type, :atom do
      constraints one_of: [:influencer, :business, :admin]
      default :influencer
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :active, :suspended]
      default :pending
      public? true
    end
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_email, [:email]
  end

  actions do
    defaults [:read]
    default_accept [:email, :phone, :user_type]

    create :create do
      accept [:email, :phone, :user_type]
      primary? true
    end

    update :update do
      accept [:phone, :status]
      primary? true
    end
  end
end
