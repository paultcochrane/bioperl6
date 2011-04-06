use v6;

BEGIN {
    @*INC.push('./lib');
}

use Test;
plan 158;
eval_lives_ok('Bio::Annotation::Collection','Can load Bio::Annotation::Collection');
eval_lives_ok('Bio::Annotation::DBLink','Can load Bio::Annotation::DBLink');
eval_lives_ok('Bio::Annotation::Comment','Can load Bio::Annotation::Comment');
eval_lives_ok('Bio::Annotation::Reference','Can load Bio::Annotation::Reference');
eval_lives_ok('Bio::Annotation::Target','Can load Bio::Annotation::Target');
eval_lives_ok('Bio::Annotation::AnnotationFactory','Can load Bio::Annotation::AnnotationFactory');
eval_lives_ok('Bio::Annotation::StructuredValue','Can load Bio::Annotation::StructuredValue');
eval_lives_ok('Bio::Annotation::TagTree');
eval_lives_ok('Bio::Annotation::Tree');
eval_lives_ok('Bio::Annotation::OntologyTerm','Can load Bio::Annotation::OntologyTerm');
eval_lives_ok('Bio::Seq');
eval_lives_ok('Bio::SimpleAlign');
eval_lives_ok('Bio::Cluster::UniGene');
eval_lives_ok('Bio::Annotation::SimpleValue','Can load Bio::Annotation::SimpleValue');

use Bio::Annotation::SimpleValue;
use Bio::Annotation::DBLink;
use Bio::Annotation::Reference;
use Bio::Annotation::Comment;
use Bio::Annotation::Target;
use Bio::Annotation::Collection;
use Bio::Annotation::StructuredValue;
use Bio::Annotation::AnnotationFactory;
use Bio::Annotation::OntologyTerm;

#simple value
my $simple = Bio::Annotation::SimpleValue.new(tagname => 'colour',
					       value   => '1',
					      );

ok($simple ~~ Bio::AnnotationI);
is $simple.display_text, 1;
is $simple.as_text, 'Value: 1';
is $simple.value, 1;
is $simple.tagname, 'colour';
is $simple.tag_term, Any;
is $simple.hash_tree.{'value'},1;
is $simple.value(0), 0;
is $simple.value, 0;
is $simple.display_text, 0;

# link
my $link1 = Bio::Annotation::DBLink.new(database => 'TSC',
					 primary_id => 'TSC0000030',
					);
ok($link1 ~~ Bio::AnnotationI);
is $link1.database(), 'TSC';
is $link1.primary_id(), 'TSC0000030';
is $link1.as_text, 'Direct database link to TSC0000030 in database TSC';
is $link1.display_text, 'TSC:TSC0000030';

my $ac = Bio::Annotation::Collection.new();
ok($ac ~~ Bio::AnnotationCollectionI);


$ac.add_Annotation('dblink',$link1);
$ac.add_Annotation('dblink',
                   Bio::Annotation::DBLink.new(database => 'TSC',
                                               primary_id => 'HUM_FABV'));

my $comment = Bio::Annotation::Comment.new( text => 'sometext');
is $comment.text, 'sometext';
is $comment.as_text, 'Comment: sometext';
is $comment.display_text(), 'sometext';
is $comment.display_text( sub ($self) { $self.text ~ ' appending test'}), 'sometext appending test';
is $comment.hash_tree.{'text'},'sometext';
is $comment.value,'sometext';
is $comment.value('boo'),'boo';
is $comment.type('comment type'),'comment type';

my $comment2 = Bio::Annotation::Comment.new( text => 'more text' , tagname => 'celluar');
is $comment2.tagname,'celluar';


$ac.add_Annotation('comment', $comment);

my $target = Bio::Annotation::Target.new(target_id  => 'F321966.1',
 					  start      => 1,
 					  end        => 200,
 					  strand     => 1,
 					 );

ok($target ~~ Bio::AnnotationI);
ok $ac.add_Annotation('target', $target);


my $ref = Bio::Annotation::Reference.new( authors  => 'author line',
 					   title    => 'title line',
 					   location => 'location line',
 					   start    => 12);
ok($ref ~~ Bio::AnnotationI);
is $ref.authors, 'author line';
is $ref.title,  'title line';
is $ref.location, 'location line';
is $ref.start, 12;
is $ref.database, 'MEDLINE';
is $ref.as_text, 'Reference: title line';
is $ref.display_text, 'title line';
is $ref.display_text( sub ($self) { $self.title ~ ' ' ~ $self.start}), 'title line 12';
is $ref.end,Any;
is $ref.rp,Any;
is $ref.rg,Any;
is $ref.publisher,Any;
is $ref.editors,Any;
is $ref.encoded_ref,Any;
is $ref.doi,Any;
is $ref.consortium,Any;
is $ref.gb_reference,Any;


my %items = $ref.hash_tree;
is %items{'title'},'title line';
is %items{'authors'},'author line';
is  %items.exists('end'),False;

$ac.add_Annotation('reference', $ref);


my $n = 0;
for ( $ac.get_Annotations('dblink') ) -> $link {
     is $link.database, 'TSC';
     is $link.tagname(), 'dblink';
     $n++;
}
is($n, 2);

$n = 0;
my @keys = $ac.get_all_annotation_keys();
is(@keys.elems, 4);
for ( $ac.get_Annotations() ) -> $ann {
    shift(@keys) if ($n > 0) && ($ann.tagname ne @keys[0]);
    is $ann.tagname(), @keys[0];
    $n++;
}
is($n, 5);

$ac.add_Annotation($link1);

$n = 0;
for ( $ac.get_Annotations('dblink') ) -> $link {
     is $link.tagname(), 'dblink';
     $n++;
}
is($n, 3);

# annotation of structured simple values (like swissprot''is GN line)
my $ann = Bio::Annotation::StructuredValue.new();
ok($ann ~~ Bio::AnnotationI);

$ann.add_value([-1], "val1");
is($ann.value(), "val1");
$ann.value("compat test");
is($ann.value(), "compat test");
$ann.add_value([-1], "val2");
is($ann.value(joins => [" AND "]), "compat test AND val2");
$ann.add_value([0], "val1");
is($ann.value(joins => [" AND "]), "val1 AND val2");
$ann.add_value([-1,-1], "val3", "val4");
$ann.add_value([-1,-1], "val5", "val6");
$ann.add_value([-1,-1], "val7");
is($ann.value(joins => [" AND "]), "val1 AND val2 AND (val3 AND val4) AND (val5 AND val6) AND val7");
is($ann.value(joins => [" AND ", " OR "]), "val1 AND val2 AND (val3 OR val4) AND (val5 OR val6) AND val7");

$n = 1;
for ($ann.get_all_values()) {
     is($_, "val" ~ $n++);
}

# nested collections
my $nested_ac = Bio::Annotation::Collection.new();
$nested_ac.add_Annotation('nested', $ac);

is($nested_ac.get_Annotations().elems, 1);
($ac) = $nested_ac.get_Annotations();
ok($ann ~~ Bio::AnnotationI);
is($nested_ac.get_all_Annotations().elems, 6);
$nested_ac.add_Annotation('gene names', $ann);
is($nested_ac.get_Annotations().elems, 2);
is($nested_ac.get_all_Annotations().elems, 7);
is($nested_ac.get_Annotations('dblink').elems, 0);
my @anns = $nested_ac.get_Annotations('gene names');
ok(@anns[0] ~~ Bio::Annotation::StructuredValue);
 @anns = map { $_.get_Annotations('dblink');
 	  } , $nested_ac.get_Annotations('nested');
is(@anns.elems, 3);
is($nested_ac.flatten_Annotations().elems, 2);
is($nested_ac.get_Annotations().elems, 7);
is($nested_ac.get_all_Annotations().elems, 7);

# SKIP: {
#   test_skip(-tests => 7, -requires_modules => [qw(Graph::Directed Bio::Annotation::OntologyTerm)]);
#   use_ok('Bio::Annotation::OntologyTerm');
#   # OntologyTerm annotation
#   my $termann = Bio::Annotation::OntologyTerm.new(label => 'test case',
# 						   identifier => 'Ann:00001',
# 						   ontology => 'dumpster');
#   isa_ok($termann.term,'Bio::Ontology::Term');
#   is($termann.term.name, 'test case');
#   is($termann.term.identifier, 'Ann:00001');
#   is($termann.tagname, 'dumpster');
#   is($termann.ontology.name, 'dumpster');
#   is($termann.as_text, "dumpster|test case|");
# }

# AnnotatableI
# my $seq = Bio::Seq.new();
# isa_ok($seq,"Bio::AnnotatableI");
# SKIP: {
# 	test_skip(-requires_modules => [qw(Bio::SeqFeature::Annotated URI::Escape)],
# 			  -tests => 4);
# 	my $fea = Bio::SeqFeature::Annotated.new();
# 	isa_ok($fea, "Bio::SeqFeatureI",'isa SeqFeatureI');
# 	isa_ok($fea, "Bio::AnnotatableI",'isa AnnotatableI');
# 	$fea = Bio::SeqFeature::Generic.new();
# 	isa_ok($fea, "Bio::SeqFeatureI",'isa SeqFeatureI');
# 	isa_ok($fea, "Bio::AnnotatableI",'isa AnnotatableI');
# }
# my $clu = Bio::Cluster::UniGene.new();
# isa_ok($clu, "Bio::AnnotatableI");
# my $aln = Bio::SimpleAlign.new();
# isa_ok($clu,"Bio::AnnotatableI");

# tests for Bio::Annotation::AnnotationFactory

my $factory = Bio::Annotation::AnnotationFactory.new;
#ok($factory ~~ Bio::Factory::ObjectFactoryI);

# defaults to SimpleValue
 $ann = $factory.create_object(value => 'peroxisome',
 			       tagname => 'cellular component');
ok($ann ~~ Bio::Annotation::SimpleValue);


# $factory.type('Bio::Annotation::OntologyTerm');

$ann = $factory.create_object(name => 'peroxisome',
 			       tagname => 'cellular component');
ok(defined $ann,'Bio::Annotation::OntologyTerm');
ok($ann ~~ Bio::Annotation::OntologyTerm);

# unset type()
$factory.type(Any);
$ann = $factory.create_object(text => 'this is a comment');
ok(defined $ann,'Bio::Annotation::Comment');
ok($ann ~~ Bio::Annotation::Comment,'Isa Bio::Annotation::Comment');
my $x= Bio::Annotation::Comment;
ok($factory.type( Bio::Annotation::Comment ),Bio::Annotation::Comment );
$ann = $factory.create_object(text => 'this is a comment');
ok(defined $ann,'Bio::Annotation::Comment');
ok($ann ~~ Bio::Annotation::Comment);

# factory guessing the type: Comment
$factory = Bio::Annotation::AnnotationFactory.new();
$ann = $factory.create_object(text => 'this is a comment');
ok(defined $ann,'Bio::Annotation::Comment');
ok($ann ~~ Bio::Annotation::Comment);

# factory guessing the type: Target
$factory = Bio::Annotation::AnnotationFactory.new();
$ann = $factory.create_object(target_id => 'F1234',
 			       start     => 1,
 			       end       => 10 );
ok defined $ann;
isa_ok($ann,'Bio::Annotation::Target');



# factory guessing the type: OntologyTerm
$factory = Bio::Annotation::AnnotationFactory.new();
ok(defined ($ann = $factory.create_object(name => 'peroxisome',
 					   tagname => 'cellular component')));
# like(ref $ann, qr(Bio::Annotation::OntologyTerm));

# tree
# my $tree_filename = test_input_file('longnames.dnd');
# my $tree = Bio::TreeIO.new(file=>$tree_filename).next_tree();
# my $ann_tree = Bio::Annotation::Tree.new(
# 					  tagname  => 'tree',
# 					  tree_obj => $tree,
# 					 );

# isa_ok($ann_tree, 'Bio::AnnotationI');
# $ann_tree.tree_id('test');
# is $ann_tree.tree_id(), 'test', "tree_id()";
# $ann_tree.tagname('tree'); 
# is $ann_tree.tagname(), 'tree', "tagname()";
# my $aln_filename = test_input_file('longnames.aln');
# use Bio::AlignIO;
# $aln = Bio::AlignIO.new(file  => $aln_filename,
# 			 format=>'clustalw').next_aln();
# isa_ok($aln, 'Bio::AnnotatableI');
# $ac = Bio::Annotation::Collection.new();
# $ac.add_Annotation('tree',$ann_tree);
# $aln.annotation($ac);
# for my $treeblock ( $aln.annotation.get_Annotations('tree') ) {
#   my $treeref = $treeblock.tree();
#   my @nodes = sort { defined $a.id &&
# 		       defined $b.id &&
# 			 $a.id cmp $b.id } $treeref.get_nodes();
#   is $nodes[12].id, '183.m01790', "add tree to AlignI";
#   my $str;
#   for my $seq ($aln.each_seq_with_id($nodes[12].id)) {
#     $str = $seq.subseq(1,20);
#   }
#   is( $str, "MDDKELEIPVEHSTAFGQLV", "get seq from node id");
# }

# # factory guessing the type: Tree
# $factory = Bio::Annotation::AnnotationFactory.new();
# $ann = $factory.create_object(tree_obj => $tree);
# ok defined $ann;
# isa_ok($ann,'Bio::Annotation::Tree');

# #tagtree
# my $struct = [ 'genenames' => [
# 			       ['genename' => [
# 					       [ 'Name' => 'CALM1' ],
# 					       ['Synonyms'=> 'CAM1'],
# 					       ['Synonyms'=> 'CALM'],
# 					       ['Synonyms'=> 'CAM' ] ] ],
# 			       ['genename'=> [
# 					      [ 'Name'=> 'CALM2' ],
# 					      [ 'Synonyms'=> 'CAM2'],
# 					      [ 'Synonyms'=> 'CAMB'] ] ],
# 			       [ 'genename'=> [
# 					       [ 'Name'=> 'CALM3' ],
# 					       [ 'Synonyms'=> 'CAM3' ],
# 					       [ 'Synonyms'=> 'CAMC' ] ] ]
# 			      ] ];

# my $ann_struct = Bio::Annotation::TagTree.new(tagname => 'gn',
# 					       value => $struct);

# isa_ok($ann_struct, 'Bio::AnnotationI');
# my $val = $ann_struct.value;
# like($val, qr/Name: CALM1/,'default itext');

# roundtrip
# my $ann_struct2 = Bio::Annotation::TagTree.new(tagname => 'gn',
# 						value => $val);
# is($ann_struct2.value, $val,'roundtrip');

# formats 
# like($ann_struct2.value, qr/Name: CALM1/,'itext');
# $ann_struct2.tagformat('sxpr');
# like($ann_struct2.value, qr/\(Name "CALM1"\)/,'spxr');
# $ann_struct2.tagformat('indent');
# like($ann_struct2.value, qr/Name "CALM1"/,'indent');

# SKIP: {
#     eval {require XML::Parser::PerlSAX};
#     skip ("XML::Parser::PerlSAX rquired for XML",1) if $@;
#     $ann_struct2.tagformat('xml');
#     like($ann_struct2.value, qr/<Name>CALM1<\/Name>/,'xml');
# }

# grab Data::Stag nodes, use Data::Stag methods
# my @nodes = $ann_struct2.children;
# for my $node (@nodes) {
#     isa_ok($node, 'Data::Stag::StagI');
#     is($node.element, 'genename');
#     # add tag-value data to node
#     $node.set('foo', 'bar');
#     # check output
#     like($node.itext, qr/foo:\s+bar/,'child changes');
# }

# $ann_struct2.tagformat('itext');
# like($ann_struct2.value, qr/foo:\s+bar/,'child changes in parent node');

# pass in a Data::Stag node to value()
# $ann_struct = Bio::Annotation::TagTree.new(tagname => 'mytags');
# like($ann_struct.value, qr/^\s+:\s+$/xms, 'no tags');
# like($ann_struct.value, qr/^\s+:\s+$/xms,'before Stag node');
# $ann_struct.value($nodes[0]);
# like($ann_struct.value, qr/Name: CALM1/,'after Stag node');
# is(ref $ann_struct.node, ref $nodes[0], 'both stag nodes');
# isnt($ann_struct.node, $nodes[0], 'different instances');

# pass in another TagTree to value()
# $ann_struct = Bio::Annotation::TagTree.new(tagname => 'mytags');
# like($ann_struct.value, qr/^\s+:\s+$/xms,'before TagTree');
# $ann_struct.value($ann_struct2);
# like($ann_struct.value, qr/Name: CALM2/,'after TagTree');
# is(ref $ann_struct.node, ref $ann_struct2.node, 'both stag nodes');
# isnt($ann_struct.node, $ann_struct2.node, 'different instances');

# replace the Data::Stag node in the annotation (no copy)
# $ann_struct = Bio::Annotation::TagTree.new(tagname => 'mytags');
# like($ann_struct.value, qr/^\s+:\s+$/xms,'before TagTree');
# $ann_struct.node($nodes[1]);
# like($ann_struct.value, qr/Name: CALM2/,'after TagTree');
# is(ref $ann_struct.node, ref $ann_struct2.node, 'stag nodes');
# is($ann_struct.node, $nodes[1], 'same instance');
# # replace the Data::Stag node in the annotation (use duplicate)
# $ann_struct = Bio::Annotation::TagTree.new(tagname => 'mytags');
# like($ann_struct.value, qr/^\s+:\s+$/xms,'before TagTree');
# $ann_struct.node($nodes[1],'copy');
# like($ann_struct.value, qr/Name: CALM2/,'after TagTree');
# is(ref $ann_struct.node, ref $ann_struct2.node, 'stag nodes');
# isnt($ann_struct.node, $nodes[1], 'different instance');

#check insertion in to collection
# $ann_struct = Bio::Annotation::TagTree.new(value => $struct);
# $ac = Bio::Annotation::Collection.new();

# $ac.add_Annotation('genenames',$ann_struct);
# my $ct = 0;
# for my $tagtree ( $ac.get_Annotations('genenames') ) {
#   isa_ok($tagtree, 'Bio::AnnotationI');
#   for my $node ($tagtree.children) {
#     isa_ok($node, 'Data::Stag::StagI');
#     like($node.itext, qr/Name:\s+CALM/,'child changes');
#     $ct++;
#   }
# }
# is($ct,3);

# factory guessing the type: TagTree
# $factory = Bio::Annotation::AnnotationFactory.new();
# $ann = $factory.create_object(value => $struct);
# ok defined $ann;
# isa_ok($ann,'Bio::Annotation::TagTree');

done();
