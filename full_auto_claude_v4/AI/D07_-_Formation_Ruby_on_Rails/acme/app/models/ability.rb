class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Product, Brand]

    return unless user.present?

    can :manage, Cart
    can :manage, CartItem
    can :read, Order, user_id: user.id

    if user.has_role?(:admin)
      can :manage, :all
      can :access, :rails_admin
      can :read, :dashboard
    elsif user.has_role?(:mod)
      can :manage, Product
      can :manage, Brand
      can :access, :rails_admin
      can :read, :dashboard
    end
  end
end
