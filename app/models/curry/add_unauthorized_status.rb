#
# Adds a successful status to a pull request
#
class Curry::AddUnauthorizedStatus
  #
  # Creates a new +Curry::AddUnauthorizedStatus+
  #
  # @param octokit [Octokit::Client]
  # @param pull_request [Curry::PullRequest]
  #
  def initialize(octokit, pull_request)
    @octokit = octokit
    @pull_request = pull_request
  end

  #
  # Performs the action of adding the label
  #
  def call
    @octokit.add_labels_to_an_issue(
      @pull_request.repository.full_name,
      @pull_request.head.sha,
      "failure",
      { context: "Chef CLA", description: "Please sign the CLA", url: ENV['CURRY_CLA_LOCATION'] }
    )
  end
end
