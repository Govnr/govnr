class User < ActiveRecord::Base
	acts_as_voter
	acts_as_messageable

    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable

	before_create :skip_confirmation

	def name
		return self.first_name + ' ' + self.last_name
	end

	ROLES = %i[moderator admin]

    def has_role?(role)
      roles.include?(role)
    end

	def skip_confirmation
	  self.skip_confirmation! if Rails.env.development?
	end

	def roles=(roles)
	  roles = [*roles].map { |r| r.to_sym }
	  self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
	end

	def roles
	  ROLES.reject do |r|
	    ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
	  end
	end

	attr_accessible :first_name, :last_name, :address, :postcode, :email, :roles, :password, :password_confirmation

	# attr_accessor :password
	#   EMAIL_REGEX = /A[w+-.]+@[a-zd-.]+.[a-z]+z/i
	#   validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
	#   validates :password, :confirmation => true #password_confirmation attr
	#   validates_length_of :password, :in => 6..20, :on => :create

	# before_save :encrypt_password
	# after_save :clear_password
	# def encrypt_password
	#   if password.present?
	#     self.salt = BCrypt::Engine.generate_salt
	#     self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
	#   end
	# end
	# def clear_password
	#   self.password = nil
	# end

	# def self.authenticate(email="", login_password="")
	#   if  EMAIL_REGEX.match(email)    
	#     user = User.find_by_email(email)
	#   end
	#   if user && user.match_password(login_password)
	#     return user
	#   else
	#     return false
	#   end
	# end   
	
	# def match_password(login_password="")
	#   encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
	# end

end
