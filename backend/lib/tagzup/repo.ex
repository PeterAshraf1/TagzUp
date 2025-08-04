# lib/tagzup/repo.ex

defmodule TagzUp.Repo do
  use AshPostgres.Repo,
    otp_app: :tagzup

  # Add minimum PostgreSQL version
  def min_pg_version do
    %Version{major: 14, minor: 0, patch: 0}
  end

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
