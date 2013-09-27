class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    elsif user.host?
      can :read, :all
      can :manage, [Episode, Discussion, Reply]
    elsif user.listener?
      can :read, :all
      can [:create, :vote], Reply
    else
      can :read, :all
    end
  end

  # ----------------------
  # Class Methods
  # ----------------------

  def self.rules_for_role(role)
    user = User.new
    user.role = role
    ability = Ability.new(user)

    ability.send 'rules'
  end

  # Public: Get the mapping of roles to rules for all roles.
  #
  # Returns hash of role to its rule set
  def self.rules_for_all_roles
    rules = {}
    User::ROLES.each do |role|
      rules[role] = rules_for_role(role)
    end

    rules
  end

  # Public: Get the rules for all roles in a convenient hash.
  #
  # Examples
  #   roles_subjects_actions =
  #     'role1':
  #       'subject1': ['edit', 'create']
  #       ...
  #     'role2':
  #     ...
  # Returns a hash of roles to subjects to an array of string actions.
  def self.rules_map_for_all_roles
    roles_to_subjects = {}
    Ability.rules_for_all_roles.each_pair do |role, rules|
      roles_to_subjects[role] ||= {}

      rules.each do |rule|
        actions = rule.actions
        subjects = rule.subjects

        subjects.each do |subject|
          subject = subject.to_s.downcase
          roles_to_subjects[role][subject] ||= []
          roles_to_subjects[role][subject] << actions
          roles_to_subjects[role][subject].flatten!
        end
      end
    end

    roles_to_subjects
  end

end
