var search_data = {"index":{"searchIndex":["object","x12","base","composite","empty","field","loop","parser","segment","table","xmldefinitions","[]()","apply_overrides()","apply_overrides()","do_repeats()","dup()","empty?()","empty?()","empty?()","factory()","find()","find()","find()","find_field()","has_content?()","has_content?()","inspect()","inspect()","inspect()","inspect()","is_constant?()","is_variable?()","method_missing()","new()","new()","new()","new()","new()","new()","new()","new()","parse()","parse()","parse()","parse()","proper_regexp()","raw_value()","regexp()","render()","render()","render()","render()","repeat()","segments_parsed()","segments_parsed()","set_empty!()","set_empty!()","show()","simple_regexp()","size()","to_a()","to_hsh()","to_hsh()","to_s()","valid?()","validate()","validate!()","var_value()","with()","changelog","readme","todo"],"longSearchIndex":["object","x12","x12::base","x12::composite","x12::empty","x12::field","x12::loop","x12::parser","x12::segment","x12::table","x12::xmldefinitions","x12::base#[]()","x12::field#apply_overrides()","x12::segment#apply_overrides()","x12::base#do_repeats()","x12::base#dup()","x12::base#empty?()","x12::empty#empty?()","x12::field#empty?()","x12::parser#factory()","x12::base#find()","x12::loop#find()","x12::segment#find()","x12::segment#find_field()","x12::base#has_content?()","x12::field#has_content?()","x12::base#inspect()","x12::composite#inspect()","x12::field#inspect()","x12::table#inspect()","x12::field#is_constant?()","x12::field#is_variable?()","x12::base#method_missing()","x12::base::new()","x12::empty::new()","x12::field::new()","x12::loop::new()","x12::parser::new()","x12::segment::new()","x12::table::new()","x12::xmldefinitions::new()","x12::field#parse()","x12::loop#parse()","x12::parser#parse()","x12::segment#parse()","x12::field#proper_regexp()","x12::field#raw_value()","x12::segment#regexp()","x12::empty#render()","x12::field#render()","x12::loop#render()","x12::segment#render()","x12::base#repeat()","x12::loop#segments_parsed()","x12::segment#segments_parsed()","x12::base#set_empty!()","x12::field#set_empty!()","x12::base#show()","x12::field#simple_regexp()","x12::base#size()","x12::base#to_a()","x12::loop#to_hsh()","x12::segment#to_hsh()","x12::base#to_s()","x12::field#valid?()","x12::parser#validate()","x12::parser#validate!()","x12::field#var_value()","x12::base#with()","","",""],"info":[["Object","","Object.html","",""],["X12","","X12.html","","<p>$Id: X12.rb 91 2009-05-13 22:11:10Z ikk $\n<p>Package implementing direct manipulation of X12 structures using …\n"],["X12::Base","","X12/Base.html","","<p>$Id: Base.rb 70 2009-03-26 19:25:39Z ikk $\n<p>Base class for Segment, Composite, and Loop. Contains setable …\n"],["X12::Composite","","X12/Composite.html","","<p>$Id: Composite.rb 35 2008-11-13 18:33:44Z ikk $\n<p>Class implementing a composite field.\n"],["X12::Empty","","X12/Empty.html","","<p>$Id: Empty.rb 35 2008-11-13 18:33:44Z ikk $\n<p>Class indicating the absense of any X12 element, be it loop, …\n"],["X12::Field","","X12/Field.html","","<p>$Id: Field.rb 90 2009-05-13 19:51:27Z ikk $\n<p>Class to represent a segment field. Please note, it’s not …\n"],["X12::Loop","","X12/Loop.html","","<p>$Id: Loop.rb 59 2009-03-19 22:32:13Z ikk $\n<p>Implements nested loops of segments\n"],["X12::Parser","","X12/Parser.html","","<p>$Id: Parser.rb 89 2009-05-13 19:36:20Z ikk $\n<p>Main class for creating X12 parsers and factories.\n"],["X12::Segment","","X12/Segment.html","","<p>$Id: Segment.rb 82 2009-05-13 18:07:22Z ikk $\n<p>Implements a segment containing fields or composites\n"],["X12::Table","","X12/Table.html","","<p>$Id: Table.rb 35 2008-11-13 18:33:44Z ikk $\n<p>This just a named hash to store validation tables.\n"],["X12::XMLDefinitions","","X12/XMLDefinitions.html","","<p>$Id: XMLDefinitions.rb 90 2009-05-13 19:51:27Z ikk $\n<p>A class for parsing X12 message definition expressed …\n"],["[]","X12::Base","X12/Base.html#method-i-5B-5D","(*args)","<p>The main method implementing Ruby-like access methods for repeating\nelements\n"],["apply_overrides","X12::Field","X12/Field.html#method-i-apply_overrides","(override_field)",""],["apply_overrides","X12::Segment","X12/Segment.html#method-i-apply_overrides","()","<p>Replaces fields loaded from definition skeleton for which overrides exist\n\n<pre>with their clones with overrides ...</pre>\n"],["do_repeats","X12::Base","X12/Base.html#method-i-do_repeats","(s)","<p>Try to parse the current element one more time if required. Returns the\nrest of the string or the same …\n"],["dup","X12::Base","X12/Base.html#method-i-dup","()","<p>Make a deep copy of the element\n"],["empty?","X12::Base","X12/Base.html#method-i-empty-3F","()",""],["empty?","X12::Empty","X12/Empty.html#method-i-empty-3F","()",""],["empty?","X12::Field","X12/Field.html#method-i-empty-3F","()",""],["factory","X12::Parser","X12/Parser.html#method-i-factory","(loop_name)","<p>Make an empty loop to be filled out with information\n"],["find","X12::Base","X12/Base.html#method-i-find","(e)","<p>Method to be overloaded\n"],["find","X12::Loop","X12/Loop.html#method-i-find","(name)","<p>Recursively find a sub-element\n"],["find","X12::Segment","X12/Segment.html#method-i-find","(name)","<p>Recursively find a sub-element\n"],["find_field","X12::Segment","X12/Segment.html#method-i-find_field","(field_name)","<p>Finds a field in the segment. Returns EMPTY if not found.\n"],["has_content?","X12::Base","X12/Base.html#method-i-has_content-3F","()","<p>Check if any of the fields has been set yet\n"],["has_content?","X12::Field","X12/Field.html#method-i-has_content-3F","()","<p>Check if it’s been set yet and it’s not a constant.\n"],["inspect","X12::Base","X12/Base.html#method-i-inspect","()","<p>Formats a printable string containing the base element’s content\n"],["inspect","X12::Composite","X12/Composite.html#method-i-inspect","()","<p>Make a printable representation of the composite\n"],["inspect","X12::Field","X12/Field.html#method-i-inspect","()","<p>Returns printable string with field’s content\n"],["inspect","X12::Table","X12/Table.html#method-i-inspect","()","<p>Return a printable string representing this table\n"],["is_constant?","X12::Field","X12/Field.html#method-i-is_constant-3F","()",""],["is_variable?","X12::Field","X12/Field.html#method-i-is_variable-3F","()",""],["method_missing","X12::Base","X12/Base.html#method-i-method_missing","(meth, *args, &block)","<p>The main method implementing Ruby-like access methods for nested elements\n"],["new","X12::Base","X12/Base.html#method-c-new","(params = {}, nodes = [])","<p>Creates a new base element with a given name, array of sub-elements, and\narray of repeats if any.\n"],["new","X12::Empty","X12/Empty.html#method-c-new","()","<p>Create a new empty\n"],["new","X12::Field","X12/Field.html#method-c-new","(params = {})","<p>Create a new field with given parameters\n"],["new","X12::Loop","X12/Loop.html#method-c-new","(*args)",""],["new","X12::Parser","X12/Parser.html#method-c-new","(file_name)","<p>Creates a parser out of a definition\n"],["new","X12::Segment","X12/Segment.html#method-c-new","(params, nodes)",""],["new","X12::Table","X12/Table.html#method-c-new","(params, nodes)","<p>Create a new table with given name and hash content.\n"],["new","X12::XMLDefinitions","X12/XMLDefinitions.html#method-c-new","(str)","<p>Parse definitions out of XML file\n"],["parse","X12::Field","X12/Field.html#method-i-parse","(str)",""],["parse","X12::Loop","X12/Loop.html#method-i-parse","(str)","<p>Parse a string and fill out internal structures with the pieces of it.\nReturns  an unparsed portion of …\n"],["parse","X12::Parser","X12/Parser.html#method-i-parse","(loop_name, str)","<p>Parse a loop of a given name out of a string. Throws an exception if the\nloop name is not defined.\n"],["parse","X12::Segment","X12/Segment.html#method-i-parse","(str)","<p>Parses this segment out of a string, puts the match into value, returns the\nrest of the string - nil …\n"],["proper_regexp","X12::Field","X12/Field.html#method-i-proper_regexp","(field_sep, segment_sep)","<p>Returns proper validating string regexp for this field, takes field\nseparator and segment separator as …\n"],["raw_value","X12::Field","X12/Field.html#method-i-raw_value","()",""],["regexp","X12::Segment","X12/Segment.html#method-i-regexp","()","<p>Returns a regexp that matches this particular segment\n"],["render","X12::Empty","X12/Empty.html#method-i-render","()",""],["render","X12::Field","X12/Field.html#method-i-render","(root = self)","<p>Returns string representation of the field’s content formatted to X12 specs\n"],["render","X12::Loop","X12/Loop.html#method-i-render","(root = self)","<p>Render all components of this loop as string suitable for EDI\n"],["render","X12::Segment","X12/Segment.html#method-i-render","(root = self)","<p>Render all components of this segment as string suitable for EDI\n"],["repeat","X12::Base","X12/Base.html#method-i-repeat","()","<p>Adds a repeat to a segment or loop. Returns a new segment/loop or self if\nempty.\n"],["segments_parsed","X12::Loop","X12/Loop.html#method-i-segments_parsed","(include_repeats = false)","<p>Segment count should include all the segments inside this particular\ninstance of the loop.\n\n<pre>It means that ...</pre>\n"],["segments_parsed","X12::Segment","X12/Segment.html#method-i-segments_parsed","(include_repeats = false)",""],["set_empty!","X12::Base","X12/Base.html#method-i-set_empty-21","()","<p>Empty out the current element\n"],["set_empty!","X12::Field","X12/Field.html#method-i-set_empty-21","()","<p>Erase the content\n"],["show","X12::Base","X12/Base.html#method-i-show","(ind = '')","<p>Prints a tree-like representation of the element\n"],["simple_regexp","X12::Field","X12/Field.html#method-i-simple_regexp","(field_sep, segment_sep)","<p>Returns simplified string regexp for this field, takes field separator and\nsegment separator as arguments …\n"],["size","X12::Base","X12/Base.html#method-i-size","()","<p>Returns number of repeats\n"],["to_a","X12::Base","X12/Base.html#method-i-to_a","()","<p>Present self and all repeats as an array with self being #0\n"],["to_hsh","X12::Loop","X12/Loop.html#method-i-to_hsh","()","<p>Returns recursive hash of nodes that have an alias defined, along with\ntheir respective values.\n"],["to_hsh","X12::Segment","X12/Segment.html#method-i-to_hsh","()","<p>Returns the hash of fields that have an alias with their corresponding\ncontent values\n"],["to_s","X12::Base","X12/Base.html#method-i-to_s","()","<p>Returns a parsed string representation of the element\n"],["valid?","X12::Field","X12/Field.html#method-i-valid-3F","(validation_table = nil, use_ext_charset = true)","<p>Validate the field data - whether incoming or outgoing. Fields that have\nvalidation attribute set\n\n<pre>are ...</pre>\n"],["validate","X12::Parser","X12/Parser.html#method-i-validate","(node)","<p>Validates the X12 document. Returns true if the document is valid, false\notherwise; use ‘error’ attribute …\n"],["validate!","X12::Parser","X12/Parser.html#method-i-validate-21","(doc)","<p>Validates the X12 document and raises the Exception if invalid.\n"],["var_value","X12::Field","X12/Field.html#method-i-var_value","()","<p>Obtain the value corresponding to the internal variable\n"],["with","X12::Base","X12/Base.html#method-i-with","(&block)","<p>Yields to accompanying block passing self as a parameter.\n"],["CHANGELOG","","CHANGELOG.html","","<p>CHANGELOG\n<p>$Id: CHANGELOG 92 2009-05-13 22:12:10Z ikk $\n<p>5/15/09 - Release 1.1.0\n"],["README","","README.html","","<p>X12Parser - a library to manipulate X12 structures using native Ruby syntax\n<p>$Id: README 92 2009-05-13 …\n"],["TODO","","TODO.html","","<p>TODO list\n<p>$Id: TODO 35 2008-11-13 18:33:44Z ikk $\n<p>Please refer to the task list on Rubyforge site for all …\n"]]}}