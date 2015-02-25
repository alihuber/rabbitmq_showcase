Rails.application.routes.draw do
  root to: "smoke_test#index"
  delete "smoke_test" => "smoke_test#destroy"
end
