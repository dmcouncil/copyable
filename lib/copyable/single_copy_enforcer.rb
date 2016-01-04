# When we call some_model.create_copy! and we wish to copy the associated
# has_many models, we could end up copying a complex tree of models since
# create_copy! will be called on each associated model.
#
# Consider a data model where an owner can have many vehicles and a vehicle
# can have many amenities.  If an owner has a car with two amenities, the
# models may look like this:
#
#                     +-------------+
#                     |    OWNER    |
#                     +------^------+
#                            |
#                            |
#                            |
#                     +------+------+
#                     |   VEHICLE   |
#                     +--^-------^--+
#                        |       |
#                        |       |
#                        |       |
#             +--+-------+-+   +-+-------+--+
#             |  AMENITY   |   |  AMENITY   |
#             +------------+   +------------+
#
# If we call owner.create_copy!, and the copyable declaration of the Owner
# class and the Vehicle class instruct us to make copies of the associated
# models, we will end up with a new owner model, which has a new vehicle model,
# which has two new amenity models.  The whole tree structure gets copied.
#
# Now here's a twist.  Consider the data model is not well normalized in that
# even though an amenity belongs to a vehicle which belongs to an owner,
# there is a redundant belongs to relationship between an amenity and an owner.
# So an owner can know his amenities through his vehicles or directly:
#
#                     +-------------+
#                +---->    OWNER    <----+
#                |    +------^------+    |
#                |           |           |
#                |           |           |
#                |           |           |
#                |    +------+------+    |
#                |    |   VEHICLE   |    |
#                |    +--^-------^--+    |
#                |       |       |       |
#                |       |       |       |
#                |       |       |       |
#             +--+-------+-+   +-+-------+--+
#             |  AMENITY   |   |  AMENITY   |
#             +------------+   +------------+
#
# Now, a copying algorithm that treats this as a "tree" and simply walks through
# the associations will end up creating too many amenity records because it
# will copy the amenities belonging to the owner and then the amenities
# belonging to the vehicle (which are the same amenities).
#
# Therefore, we need a way to keep track of records we have already duplicated
# so that we don't duplicate them again in the database.  The CopyRegistry
# class keeps track of what we've already copied, and the SingleCopyEnforcer
# simply tells us whether we can go ahead and duplicate a record in the
# database (because it hasn't been duplicated yet).

module Copyable
  class SingleCopyEnforcer
    def self.can_copy?(record)
      !CopyRegistry.already_copied?(record: record)
    end
  end
end
