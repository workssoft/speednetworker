require File.expand_path("../../rails_helper", __FILE__)

RSpec.describe UserSessionsController, :type => :controller do

  describe "GET new" do
    it "returns http success" do
      get :new
      expect(response).to be_success
    end

		it "renders the new template" do
			get :new
			expect(response).to render_template(:new)
		end
  end

  describe "POST create" do
		context "with correct credentials" do

			let!(:user){ User.create(first_name: "Jason", last_name: "Seifer", email: "jason@teamtreehouse.com", password: "treehouse1234", password_confirmation: "treehouse1234") }

			it "redirects to the home path" do
				post :create, email: "jason@teamtreehouse.com", password: "treehouse1234"
				expect(response).to be_redirect
				expect(response).to redirect_to(home_index_path)
			end

			it "finds the user" do
				expect(User).to receive(:find_by).with({ email: "jason@teamtreehouse.com" }).and_return(user)	
				post :create, email: "jason@teamtreehouse.com", password: "treehouse1234"
			end

			it "authenticates the user" do
			 		User.stub(:find_by).and_return(user)	
					expect(user).to receive(:authenticate)
					post :create, email: "jason@teamtreehouse.com", password: "treehouse1234"
			end

			it "sets the user_id in the session" do
				post :create, email: "jason@teamtreehouse.com", password: "treehouse1234"
				expect(session[:user_id]).to eq(user.id)
			end

			it "sets the flash success message" do	
				post :create, email: "jason@teamtreehouse.com", password: "treehouse1234"
				expect(flash[:success]).to eq("Thanks for logging in!")
			end
		end

		shared_examples_for "denied login" do	
			it "renders the new template" do
				post :create, email: email, password: password
				expect(response).to render_template(:new)
			end
			
			it "sets the flash error message" do
				post :create ,email: email, password: password
				expect(flash[:error]).to eq("There was a problem logging in. Please check your email and password")
			end
		end


		context "with blank credentials" do
			let(:email){ "" }
			let(:password){ "" }
			it_behaves_like "denied login"	
		end


		context "with an incorrect password" do
			let!(:user){ User.create(first_name: "Jason", last_name: "Seifer", email: "jason@teamtreehouse.com", password: "treehouse1234", password_confirmation: "treehouse1234") }
			let(:email){ user.email }
			let(:password){ "incorrect" }
			it_behaves_like "denied login"
		end

		context "with no email existance" do
			let(:email){ "none@email.com" }
			let(:password){ "incorrect" }
			it_behaves_like "denied login"
		end


	end
end
