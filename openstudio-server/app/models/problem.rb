class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  #has_many :workflow_steps
  field :name, :type => String

  belongs_to :analysis

  has_many :variables

  def load_variables_from_pat_json(data)
    data[:metadata][:server_view][:variables].each do |datum|
      puts datum.inspect
      variable = self.variables.find_or_create_by(uuid: datum[:uuid])

      #save the rest of the values to the database
      datum.each_key do |key|
        next if key == 'uuid'

        variable[key] = datum[key]
      end
      variable.save!
    end
  end
end
