require './storage.rb'


class Case
  extend Storage

  attr_reader :id, :subject, :priority
  def initialize id, subject, description, creation_date, closure_date, type, status, priority, tags
    @id = id
    @subject = subject
    @description = description
    @creation_date = creation_date
    @closure_date = closure_date
    @type = type
    @status = status
    @priority = priority
    @tags = tags
  end

  def save
    self.class.save self
  end

  def status
    @status.downcase
  end

  def closed?
    @status.downcase == 'closed'
  end

  def solved?
    @status.downcase == 'solved'
  end

  def created_date
    # @creation_date.formatted_time
    @creation_date.formatted_time2
  end

  def closure_date
    # return @closure_date.formatted_time if self.solved?
    # return @closure_date.formatted_time if self.closed?
    return @closure_date.formatted_time2 if self.closed?
    ''
  end

  def type
    "Incident"
  end

  def priority
    if @priority.downcase == 'medium'
      return 'normal'
    end

    if @priority.downcase == 'urgent!'
      return 'urgent'
    end
    @priority.downcase
  end

  def description
    if @description.nil? || @description.empty? || @description == " "
      return "(blank)"
    else
      return @description
    end
  end

  def tags
    return @tags + ' legacy_tickets_2014_02_14'
  end

end

