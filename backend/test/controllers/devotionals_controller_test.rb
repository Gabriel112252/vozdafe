require_relative "../test_helper"
class DevotionalsControllerTest < ActionDispatch::IntegrationTest
  test "legacy endpoint" do
    post "/api/analyze", params: { message: "Estou com medo" }, as: :json
    assert_response :success
    assert_equal "ansiedade", response.parsed_body["theme"]
  end
  test "invalid message" do
    post "/api/v1/devotionals", params: { message: "" }, as: :json
    assert_response :unprocessable_entity
  end
  test "healthcheck" do
    get "/health"
    assert_response :success
  end
end
