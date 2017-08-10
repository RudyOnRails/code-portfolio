# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140606140404) do

  create_table "account_enrollment_credentials", :force => true do |t|
    t.string   "employee_key"
    t.string   "employer_key"
    t.string   "auth_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "employer_id"
    t.string   "employee_id"
    t.string   "name_id"
  end

  create_table "accounts", :force => true do |t|
    t.string   "email",                                                   :null => false
    t.string   "encrypted_password",    :limit => 128,                    :null => false
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.string   "referral_code"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                                :default => false
    t.boolean  "client_admin"
    t.string   "uuid",                  :limit => 36
    t.string   "saml_session_index"
    t.integer  "most_recent_family_id"
    t.string   "phone_number",          :limit => 20
    t.string   "salesforce_id",         :limit => 18
    t.string   "role_name"
  end

  add_index "accounts", ["client_id", "current_sign_in_at"], :name => "index_accounts_on_client_id_and_current_sign_in_at"
  add_index "accounts", ["confirmation_token"], :name => "index_accounts_on_confirmation_token", :unique => true
  add_index "accounts", ["confirmed_at", "client_id"], :name => "index_accounts_on_confirmed_at_and_client_id"
  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true
  add_index "accounts", ["saml_session_index"], :name => "index_accounts_on_saml_session_index"
  add_index "accounts", ["uuid"], :name => "index_accounts_on_uuid", :unique => true

  create_table "applications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "family_id"
    t.string   "uuid",                      :limit => 36
    t.decimal  "applied_tax_credit_amount",               :precision => 8, :scale => 2
    t.datetime "submitted_at",                                                          :null => false
    t.integer  "client_id"
    t.integer  "account_id"
    t.datetime "completed_at"
  end

  add_index "applications", ["account_id"], :name => "index_applications_on_account_id"
  add_index "applications", ["client_id"], :name => "index_applications_on_client_id"
  add_index "applications", ["completed_at"], :name => "index_applications_on_completed_at"
  add_index "applications", ["created_at"], :name => "index_applications_on_created_at"
  add_index "applications", ["submitted_at"], :name => "index_applications_on_submitted_at"

  create_table "benefit_specifications", :force => true do |t|
    t.string   "benefit_name"
    t.string   "pattern"
    t.string   "attribute_setting"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "benefit_tiers", :force => true do |t|
    t.integer  "benefit_id",    :limit => 8, :null => false
    t.string   "name"
    t.string   "value"
    t.string   "benefit_type"
    t.string   "coverage_tier"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "benefit_tiers", ["benefit_id"], :name => "index_benefit_tiers_on_benefit_id"
  add_index "benefit_tiers", ["name"], :name => "index_benefit_tiers_on_name"

  create_table "benefits", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "plan_id"
    t.string   "benefit_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "deductible_apply"
    t.integer  "coinsurance_value"
    t.boolean  "coinsurance_after_deductible"
    t.integer  "copay_value"
    t.boolean  "copay_after_deductible"
    t.boolean  "copay_per_day"
    t.boolean  "individual_value_includes_deductible"
    t.boolean  "family_value_includes_deductible"
    t.integer  "individual_value"
    t.integer  "family_value"
    t.string   "family_calculation_algorithm"
    t.boolean  "ignore"
    t.integer  "rx_deductible_value"
    t.integer  "copay_1_value"
    t.integer  "copay_2_value"
    t.integer  "coinsurance_1_value"
    t.integer  "coinsurance_2_value"
    t.boolean  "deductible_apply_copay"
    t.boolean  "deductible_apply_coinsurance"
    t.boolean  "ip_deductible_apply_copay"
    t.boolean  "ip_deductible_apply_coinsurance"
    t.integer  "ip_deductible_value"
    t.boolean  "deductible_apply_copay_1"
    t.boolean  "deductible_apply_copay_2"
    t.boolean  "deductible_apply_coinsurance_1"
    t.boolean  "deductible_apply_coinsurance_2"
    t.boolean  "max_visits_copay_1_apply"
    t.integer  "max_visits_copay_1_value"
    t.boolean  "max_visits_copay_2_apply"
    t.integer  "max_visits_copay_2_value"
    t.boolean  "max_visits_copay_1_and_2_apply"
    t.integer  "max_visits_copay_1_and_2_value"
    t.boolean  "deductible_apply_rx_1"
    t.boolean  "deductible_apply_rx_2"
    t.boolean  "rx_deductible_apply_rx_1"
    t.boolean  "rx_deductible_apply_rx_2"
    t.boolean  "rx_deductible_apply_copay_1"
    t.boolean  "rx_deductible_apply_copay_2"
    t.boolean  "rx_deductible_apply_coinsurance_1"
    t.boolean  "rx_deductible_apply_coinsurance_2"
    t.boolean  "recognized"
    t.string   "label"
    t.integer  "position"
  end

  add_index "benefits", ["id"], :name => "index_benefits_on_id"
  add_index "benefits", ["name"], :name => "index_benefits_on_name"
  add_index "benefits", ["plan_id"], :name => "index_benefits_on_plan_id"
  add_index "benefits", ["recognized"], :name => "index_benefits_on_recognized"

  create_table "carriers", :force => true do |t|
    t.integer  "remote_id"
    t.string   "name"
    t.string   "logo_file"
    t.text     "disclaimer_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "on_exchange",     :limit => 5, :default => "Off"
    t.string   "state",           :limit => 2
  end

  add_index "carriers", ["id"], :name => "index_carriers_on_id"
  add_index "carriers", ["remote_id"], :name => "index_carriers_on_remote_id"

  create_table "carriers_queries", :id => false, :force => true do |t|
    t.integer "carrier_id"
    t.integer "query_id"
  end

  create_table "client_settings", :force => true do |t|
    t.boolean  "request_authentication_on_landing_page", :default => false
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "group_platform",                         :default => false
    t.boolean  "send_confirmation_instructions",         :default => true
    t.text     "insurance_types"
    t.string   "email_subject_line"
    t.boolean  "browse_only",                            :default => false
    t.boolean  "evolution_one",                          :default => false
  end

  create_table "clients", :force => true do |t|
    t.string   "subdomain"
    t.text     "home_content"
    t.text     "contact_content"
    t.string   "contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "referral_code"
    t.string   "analytics_tracking_code"
    t.boolean  "cobra",                                          :default => false
    t.string   "home_content_title"
    t.string   "website"
    t.string   "name"
    t.text     "address_content"
    t.string   "phone_number"
    t.string   "home_content_title_link"
    t.string   "status",                                         :default => "Active"
    t.string   "connected_health_phone_number",   :limit => 35,  :default => "18666088020"
    t.string   "authentication_method",                          :default => "form_based"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "reply_to_address"
    t.string   "salesforce_account_id",           :limit => 32
    t.string   "salesforce_owner_id",             :limit => 32
    t.string   "salesforce_federation_id",        :limit => 20
    t.string   "salesforce_benefit_program_name", :limit => 200
    t.string   "logo_branding",                   :limit => 30
    t.boolean  "salesforce_sync"
  end

  add_index "clients", ["salesforce_account_id"], :name => "index_clients_on_salesforce_account_id"
  add_index "clients", ["salesforce_benefit_program_name"], :name => "index_clients_on_salesforce_benefit_program_name"
  add_index "clients", ["salesforce_federation_id"], :name => "index_clients_on_salesforce_federation_id"
  add_index "clients", ["salesforce_owner_id"], :name => "index_clients_on_salesforce_owner_id"
  add_index "clients", ["subdomain"], :name => "index_clients_on_subdomain", :unique => true

  create_table "clients_plans", :id => false, :force => true do |t|
    t.integer "client_id"
    t.integer "plan_id"
  end

  create_table "cms_settings", :force => true do |t|
    t.integer "client_id"
    t.string  "type"
    t.string  "right_now_email"
    t.string  "right_now_first_name"
    t.string  "right_now_last_name"
    t.string  "right_now_theme"
  end

  create_table "counties", :force => true do |t|
    t.integer  "state_id"
    t.string   "name"
    t.string   "fips"
    t.integer  "county_id"
    t.boolean  "preferred"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counties", ["county_id"], :name => "index_counties_on_county_id"
  add_index "counties", ["name"], :name => "index_counties_on_name"
  add_index "counties", ["state_id", "fips"], :name => "index_counties_on_state_id_and_fips"

  create_table "counties_zipcodes", :id => false, :force => true do |t|
    t.integer  "county_id"
    t.integer  "zipcode_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counties_zipcodes", ["county_id", "zipcode_id"], :name => "dual_index", :unique => true

  create_table "draw_custom_estimates", :force => true do |t|
    t.integer  "meps_bin_id"
    t.string   "benefit_name"
    t.integer  "expenses"
    t.integer  "utilization"
    t.string   "doctor_visit"
    t.string   "emergency_room"
    t.string   "outpatient"
    t.string   "inpatient"
    t.string   "prescription_drug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence",          :default => 1
  end

  create_table "editable_section_promoted_batches", :force => true do |t|
    t.string   "action"
    t.string   "user"
    t.integer  "custom_sections_count"
    t.integer  "default_sections_count"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.text     "clients_processed"
    t.text     "clients_skipped"
    t.integer  "skipped_sections"
  end

  create_table "editable_sections", :force => true do |t|
    t.string   "page_name"
    t.string   "section_name"
    t.text     "content"
    t.integer  "client_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "type"
    t.text     "snippets"
  end

  create_table "evo1_account_enrollment_credentials", :force => true do |t|
    t.string   "consumer_identifier"
    t.string   "employer_code"
    t.string   "administrator_alias"
    t.string   "plan_year_name"
    t.datetime "plan_year_start"
    t.integer  "account_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "agent_code"
    t.string   "agent_name"
    t.string   "agent_phone"
    t.date     "plan_year_end"
    t.boolean  "can_shop_core_med_insurance", :default => false
  end

  create_table "families", :force => true do |t|
    t.string "zip",             :limit => 10
    t.string "county"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "preferred_phone", :limit => 35
    t.string "other_phone",     :limit => 35
    t.string "fax",             :limit => 35
    t.string "first_name"
    t.string "last_name"
  end

  create_table "group_platform_shopping_cart_items", :force => true do |t|
    t.integer  "shopping_cart_id"
    t.integer  "plan_id"
    t.decimal  "rate",             :precision => 8, :scale => 2
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "coverage_code"
    t.string   "rate_frequency"
  end

  create_table "group_platform_shopping_carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "meps_bins", :force => true do |t|
    t.integer "age_min"
    t.integer "age_max"
    t.string  "gender"
    t.integer "region_id"
  end

  create_table "meps_draws", :force => true do |t|
    t.integer "meps_bin_id"
    t.string  "benefit_name"
    t.integer "expenses"
    t.integer "utilization"
    t.integer "sequence"
  end

  create_table "meps_national_estimates", :force => true do |t|
    t.integer  "meps_bin_id"
    t.string   "benefit_name"
    t.integer  "expenses"
    t.integer  "utilization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence",     :default => 1
  end

  create_table "open_enrollment_periods", :force => true do |t|
    t.integer "client_id"
    t.date    "open_date"
    t.date    "close_date"
    t.date    "effective_date"
  end

  create_table "pcp_choices", :force => true do |t|
    t.string   "name"
    t.integer  "person_id"
    t.integer  "shopping_cart_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shopping_cart_item_type", :null => false
  end

  add_index "pcp_choices", ["shopping_cart_item_id", "shopping_cart_item_type", "person_id"], :name => "index_pcp_choices_on_cart_and_person"

  create_table "people", :force => true do |t|
    t.integer "family_id"
    t.string  "gender",                :limit => 1
    t.string  "type"
    t.boolean "smoker"
    t.boolean "full_time_student"
    t.boolean "included",                            :default => true,  :null => false
    t.date    "date_of_birth"
    t.integer "height_feet"
    t.integer "height_inches"
    t.integer "weight"
    t.string  "first_name",            :limit => 50
    t.string  "family_member"
    t.string  "enrollment_id"
    t.string  "relationship"
    t.date    "smoker_last_used_date"
    t.string  "dependent_number"
    t.boolean "handicapped",                         :default => false
    t.string  "last_name",             :limit => 50
  end

  add_index "people", ["family_id"], :name => "index_people_on_family_id"
  add_index "people", ["type", "family_id"], :name => "index_people_on_type_and_family_id"

  create_table "plan_applications", :force => true do |t|
    t.integer  "application_id",                                                                        :null => false
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.string   "quote_id"
    t.string   "policy_number"
    t.integer  "shopping_cart_item_id"
    t.integer  "carrier_id"
    t.string   "carrier_name",          :limit => 100
    t.date     "effective_date"
    t.integer  "family_id"
    t.integer  "plan_id"
    t.string   "plan_name",             :limit => 100
    t.string   "plan_on_exchange",      :limit => 5,                                 :default => "Off"
    t.integer  "query_id"
    t.decimal  "rate",                                 :precision => 8, :scale => 2
  end

  add_index "plan_applications", ["family_id"], :name => "index_plan_applications_on_family_id"

  create_table "plan_carrier_info", :force => true do |t|
    t.integer  "plan_id",              :null => false
    t.string   "type",                 :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "pre_tax_contribution"
    t.boolean  "bundled"
    t.string   "product_name"
  end

  create_table "plan_external_info", :force => true do |t|
    t.boolean  "requires_pcp", :default => false
    t.string   "plan_key"
    t.string   "product_key"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_metadata", :force => true do |t|
    t.integer  "plan_id",                                      :null => false
    t.string   "metal_level"
    t.boolean  "catastrophic"
    t.string   "on_exchange"
    t.boolean  "qhp"
    t.string   "csr_level"
    t.string   "network_name"
    t.boolean  "includes_pediatric_dental"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "policy_term"
    t.integer  "max_benefit"
    t.integer  "term_life_benefit"
    t.integer  "coverage_level"
    t.string   "decorated_name"
    t.boolean  "hsa_eligible",              :default => false
  end

  create_table "plan_rules", :force => true do |t|
    t.integer "plan_id"
    t.string  "category"
    t.string  "gender",   :limit => 1
    t.integer "min_age"
    t.integer "max_age"
    t.decimal "rate",                  :precision => 8, :scale => 2
  end

  create_table "plans", :force => true do |t|
    t.string   "remote_id"
    t.integer  "carrier_id"
    t.string   "name"
    t.string   "insurance_type"
    t.string   "plan_type"
    t.string   "provider_link"
    t.string   "underwriting_link"
    t.string   "benefits_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "remote_period_id"
    t.date     "min_effective_date"
    t.date     "max_effective_date"
    t.string   "plan_category"
    t.string   "remote_sort_key"
    t.string   "internal_id"
    t.string   "variant",               :limit => 2
    t.string   "remote_insurance_type", :limit => 20
    t.boolean  "enabled",                             :default => true
  end

  add_index "plans", ["carrier_id"], :name => "index_plans_on_carrier_id"
  add_index "plans", ["id"], :name => "index_plans_on_id"
  add_index "plans", ["insurance_type"], :name => "index_plans_on_insurance_type"
  add_index "plans", ["internal_id"], :name => "index_plans_on_internal_id"
  add_index "plans", ["remote_id", "remote_period_id"], :name => "index_plans_on_remote_id_and_remote_period_id"
  add_index "plans", ["remote_id"], :name => "index_plans_on_remote_id"

  create_table "plans_service_areas", :id => false, :force => true do |t|
    t.integer  "plan_id"
    t.integer  "service_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plans_service_areas", ["plan_id", "service_area_id"], :name => "dual_index", :unique => true

  create_table "qualifying_life_events", :force => true do |t|
    t.string  "name",                                    :null => false
    t.string  "description",                             :null => false
    t.integer "ordering",                                :null => false
    t.integer "enrollment_period",       :default => 60, :null => false
    t.integer "calculation_strategy_cd",                 :null => false
  end

  add_index "qualifying_life_events", ["name"], :name => "index_qualifying_life_events_on_name"

  create_table "queries", :force => true do |t|
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "family_id"
    t.string   "insurance_type"
    t.date     "effective_date"
    t.integer  "account_id"
    t.string   "plan_types"
    t.string   "sort_field"
    t.boolean  "sort_ascending"
    t.string   "risk_tolerance_option"
    t.integer  "client_id"
    t.string   "current_job_id"
    t.text     "results",                    :limit => 2147483647
    t.text     "estimates"
    t.text     "questions"
    t.boolean  "success",                                          :default => true
    t.integer  "error_code",                                       :default => 0
    t.integer  "qualifying_life_event_id"
    t.date     "qualifying_life_event_date"
  end

  add_index "queries", ["created_at", "client_id"], :name => "index_queries_on_created_at_and_client_id"
  add_index "queries", ["family_id"], :name => "index_queries_on_family_id", :unique => true
  add_index "queries", ["qualifying_life_event_id"], :name => "index_queries_on_qualifying_life_event_id"

  create_table "quotit_monthly_import_logs", :force => true do |t|
    t.integer  "client_id"
    t.date     "effective_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "quotit_monthly_import_logs", ["client_id", "effective_date"], :name => "index_quotit_monthly_import_logs_on_client_id_and_effective_date"

  create_table "quotit_settings", :force => true do |t|
    t.integer  "client_id"
    t.string   "remote_access_key"
    t.string   "website_access_key"
    t.string   "remote_source_key"
    t.string   "broker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_load_sequence_id"
    t.string   "oes_access_key",        :limit => 50
  end

  create_table "regions", :force => true do |t|
    t.string   "name",       :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["name"], :name => "index_regions_on_name", :unique => true

  create_table "report_forms", :force => true do |t|
    t.string   "report_type"
    t.string   "title"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "recipient_email"
    t.integer  "client_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "report_forms", ["client_id"], :name => "index_report_forms_on_client_id"

  create_table "saml_settings", :force => true do |t|
    t.string   "issuer"
    t.string   "idp_sso_target_url"
    t.string   "idp_cert_fingerprint"
    t.string   "name_identifier_format"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "validate_signature",     :default => true
    t.boolean  "supports_slo",           :default => false
    t.string   "idp_slo_target_url"
    t.boolean  "requires_encryption",    :default => false, :null => false
  end

  create_table "service_areas", :force => true do |t|
    t.integer "client_id"
    t.string  "zipcode"
    t.string  "county"
    t.string  "state"
  end

  add_index "service_areas", ["client_id", "zipcode"], :name => "index_service_areas_on_client_id_and_zipcode"

  create_table "service_utilizations", :force => true do |t|
    t.integer  "min_age"
    t.integer  "max_age"
    t.string   "gender"
    t.decimal  "estimated_use",                 :precision => 9,  :scale => 3
    t.decimal  "charges_per_use",               :precision => 10, :scale => 2
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "service_code",    :limit => 10
  end

  add_index "service_utilizations", ["service_code", "min_age", "max_age", "gender", "region_id"], :name => "unique_service_utilizations", :unique => true

  create_table "services", :force => true do |t|
    t.string   "name",        :limit => 50
    t.string   "code",        :limit => 10
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["code"], :name => "index_services_on_code", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shopping_cart_items", :force => true do |t|
    t.integer  "shopping_cart_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rate",             :precision => 8, :scale => 2
    t.integer  "query_id"
  end

  create_table "shopping_carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "states", :force => true do |t|
    t.string   "name",       :limit => 50
    t.string   "code",       :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
  end

  add_index "states", ["code"], :name => "index_states_on_code", :unique => true

  create_table "status_api_keys", :force => true do |t|
    t.string  "token",      :null => false
    t.integer "account_id", :null => false
  end

  create_table "uploaded_assets", :force => true do |t|
    t.string   "name"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
  end

  create_table "waiver_informations", :force => true do |t|
    t.string   "insurance_carrier"
    t.string   "contract_holder"
    t.string   "policy_number"
    t.boolean  "has_other_medical_insurance"
    t.integer  "shopping_cart_id",            :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "waiver_informations", ["shopping_cart_id"], :name => "index_waiver_informations_on_shopping_cart_id", :unique => true

  create_table "zipcodes", :force => true do |t|
    t.string   "code"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zipcodes", ["code", "state_id"], :name => "index_zipcodes_on_code_and_state_id", :unique => true

end
