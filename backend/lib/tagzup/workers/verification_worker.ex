defmodule TagzUp.Workers.VerificationWorker do
  @moduledoc """
  Background worker for social media verification tasks
  """
  
  use Oban.Worker, queue: :verification, max_attempts: 3
  
  alias TagzUp.Services.SocialMediaVerifier
  alias TagzUp.Creators.SocialAccount
  alias TagzUp.Bookings.Proof

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "verify_social_account", "account_id" => account_id}}) do
    case SocialAccount.read(account_id) do
      {:ok, account} ->
        case SocialMediaVerifier.verify_social_account(account) do
          {:ok, _result} -> :ok
          {:error, reason} -> 
            {:error, reason}
        end
      
      {:error, _error} ->
        {:error, "Social account not found"}
    end
  end

  def perform(%Oban.Job{args: %{"type" => "verify_proof", "proof_id" => proof_id}}) do
    case Proof.read(proof_id) do
      {:ok, proof} ->
        case SocialMediaVerifier.verify_post_proof(proof) do
          {:ok, _result} -> :ok
          {:error, reason} -> 
            {:error, reason}
        end
      
      {:error, _error} ->
        {:error, "Proof not found"}
    end
  end

  def perform(%Oban.Job{args: %{"type" => "periodic_verification"}}) do
    # Verify all social accounts that haven't been verified in the last 7 days
    cutoff_date = DateTime.add(DateTime.utc_now(), -7, :day)
    
    accounts_to_verify = 
      SocialAccount.read!()
      |> Enum.filter(fn account ->
        is_nil(account.last_verified_at) or 
        DateTime.compare(account.last_verified_at, cutoff_date) == :lt
      end)

    Enum.each(accounts_to_verify, fn account ->
      %{"type" => "verify_social_account", "account_id" => account.id}
      |> __MODULE__.new()
      |> Oban.insert()
    end)

    :ok
  end

  # Helper functions to enqueue jobs
  def verify_social_account(account_id) do
    %{"type" => "verify_social_account", "account_id" => account_id}
    |> __MODULE__.new()
    |> Oban.insert()
  end

  def verify_proof(proof_id) do
    %{"type" => "verify_proof", "proof_id" => proof_id}
    |> __MODULE__.new()
    |> Oban.insert()
  end
end