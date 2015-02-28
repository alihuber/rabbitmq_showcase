Rails.application.routes.draw do
  root to: "smoke_test#index"
  get "smoke_test" => "smoke_test#index"
  get "smoke_test_ajax_progress" => "smoke_test#ajax_progress", as: "smoke_test_ajax_progress"
  delete "smoke_test" => "smoke_test#delete"
end
