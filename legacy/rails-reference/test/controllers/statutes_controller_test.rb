require 'test_helper'

class StatutesControllerTest < ActionController::TestCase
  setup do
    @statute = statutes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statutes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create statute" do
    assert_difference('Statute.count') do
      post :create, statute: { content: @statute.content, motion_id: @statute.motion_id, name: @statute.name }
    end

    assert_redirected_to statute_path(assigns(:statute))
  end

  test "should show statute" do
    get :show, id: @statute
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @statute
    assert_response :success
  end

  test "should update statute" do
    patch :update, id: @statute, statute: { content: @statute.content, motion_id: @statute.motion_id, name: @statute.name }
    assert_redirected_to statute_path(assigns(:statute))
  end

  test "should destroy statute" do
    assert_difference('Statute.count', -1) do
      delete :destroy, id: @statute
    end

    assert_redirected_to statutes_path
  end
end
