# encoding: utf-8

# create tree:
#   root = TreeNode.new("root", [
#     TreeNode.new("l1", [
#       TreeNode.new("l2", [
#         TreeNode.new("leaf1"),
#         TreeNode.new("leaf2"),
#       ]),
#       TreeNode.new("leaf3"),
#       TreeNode.new("leaf4"),
#     ]),
#     TreeNode.new("leaf5"),
#   ])
#
# add node:
#   root.add Object.new
# delete node:
#   root.children.first.delete
# print node's layer:
#   root.children.first.children.first.layer
#
class TreeNode
  attr_accessor :object, :parent, :children

  def self.link(*links)
    self.new("node:#{Time.now.object_id}", links)
  end

  def initialize(obj, children = [], parent = nil)
    @object = obj
    @children = children.flatten.map { |child| wrap(child) }
    @parent = parent if parent
  end

  def wrap(child)
    case child
    when self.class
      child.parent = self
      child
    else
      self.class.new(child, [], self)
    end
  end

  def add(child)
    children << wrap(child)
  end

  def delete
    parent.children.delete(self) if parent
  end

  def point
    if leaf?
      0 # TODO
    else
      children.sum(&:point) / children.size
    end
  end

  def root?
    parent.blank?
  end
  alias_method :top?, :root?

  def leaf?
    children.empty?
  end
  alias_method :bottom?, :leaf?

  def layer
    root? ? 0 : parent.layer + 1
  end

  def to_h
    children.inject({}) do |h, child|
      h[child] = child.to_h
      h
    end
  end

  def to_yaml
    to_h.to_yaml
  end

  def inspect_layer
    return "#{object.to_s}\n" if leaf?

    str = "#{object.to_s}:\n"
    children.each do |c|
      str << "#{'--' * c.layer}#{c.to_s}"
    end

    str
  end
end
