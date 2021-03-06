class Bio::Annotation::AnnotationFactory {
# use base qw(Bio::Root::Root Bio::Factory::ObjectFactoryI);
    #no idea why I have to put this lovely statement here - Takadonet
    use Bio::Annotation::OntologyTerm;
    
# =head2 new

#  Title   : new
#  Usage   : my $obj = Bio::Annotation::AnnotationFactory.new();
#  Function: Builds a new Bio::Annotation::AnnotationFactory object 
#  Returns : Bio::Annotation::AnnotationFactory
#  Args    : -type => string, name of a L<Bio::AnnotationI> derived class.

# If type is not set the module guesses it based on arguments passed to
# method L<create_object>.

# =cut

# method new {
#     my($class,@args) = @_;

#     my self = $class.SUPER::new(@args);
  
#     my ($type) = self._rearrange([qw(TYPE)], @args);

#     self.{'_loaded_types'} = {};
#     self.type($type) if $type;

#     return self;
# }


# =head2 create_object

#  Title   : create_object
#  Usage   : my $seq = $factory.create_object(<named parameters>);
#  Function: Instantiates new Bio::AnnotationI (or one of its child classes)

#            This object allows us to genericize the instantiation of
#            cluster objects.

#  Returns : L<Bio::AnnotationI> compliant object
#            The return type is configurable using new(-type =>"...").
#  Args    : initialization parameters specific to the type of annotation
#            object we want.

# =cut

method create_object(*%args) {

    my $type = self.type; 
    if (! $type) {
        # we need to guess this
        $type = self!guess_type(%args);
#        if(! $type) {
#        self.throw("No annotation type set and unable to guess.");
#        }
#        # load dynamically if it hasn't been loaded yet
#        if(! self.{'_loaded_types'}.{$type}) {
#        eval {
#            self._load_module($type);
#            self.{'_loaded_types'}.{$type} = 1;
#        };
#        if($@) {
#            self.throw("Bio::AnnotationI implementation $type ".
#                 "failed to load: ".$@);
#        }
#        }
    }
    
#   return $type.new(verbose => self.verbose, %args);
    return $type.new(%args);
}

# =head2 type

#  Title   : type
#  Usage   : $obj.type($newval)
#  Function: Get/set the type of L<Bio::AnnotationI> object to be created.

#            This may be changed at any time during the lifetime of this
#            factory.

#  Returns : value of type
#  Args    : newvalue (optional)


# =cut

has $!type is rw;
    
method type($type?) {

#     my $type = shift;
#     if($type && (! self.{'_loaded_types'}.{$type})) {
#         eval {
#         self._load_module($type);
#         };
#         if( $@ ) {
#         self.throw("Annotation class '$type' failed to load: ".
#                  $@);
#         }
#         my $a = bless {},$type;
#         if( ! $a.isa('Bio::AnnotationI') ) {
#         self.throw("'$type' does not implement Bio::AnnotationI. ".
#                  "Too bad.");
#         }
#         self.{'_loaded_types'}.{$type} = 1;
#     }
    #does not work with type being passed. No idea what is wrong - takadonet
    $!type = $type if defined $type;
#     }

     return $!type;
}

# =head2 !guess_type

#  Title   : !guess_type
#  Usage   :
#  Function: Guesses the right type of L<Bio::AnnotationI> implementation
#            based on initialization parameters for the prospective
#            object.
#  Example :
#  Returns : the type (a string, the module name)
#  Args    : initialization parameters to be passed to the prospective
#            cluster object


# =cut

method !guess_type(%args){
#     my (self,@args) = @_;
    my $type;

    #really not the best way to do this...
    %args{'value'} && return Bio::Annotation::SimpleValue;
    %args{'authors'} && return Bio::Annotation::Reference;
    %args{'db'} && return Bio::Annotation::DBLink;
    %args{'text'} && return Bio::Annotation::Comment;
    %args{'name'} && return Bio::Annotation::OntologyTerm;
    %args{'start'} && return Bio::Annotation::Target;
    %args{'tree'} && return Bio::Annotation::Tree;
    %args{'node'} && return Bio::Annotation::TagTree;
    
#     SWITCH: {
#         $val        && do { $type = ref($val) ? "TagTree" : "SimpleValue"; last SWITCH; };
#         $authors    && do { $type = "Reference"; last SWITCH; };
#         $db         && do { $type = "DBLink"; last SWITCH; };
#         $text       && do { $type = "Comment"; last SWITCH; };
#         $name       && do { $type = "OntologyTerm"; last SWITCH; };
#         $start      && do { $type = "Target"; last SWITCH; };
#         $tree       && do { $type = "Tree"; last SWITCH; };
#         $node       && do { $type = "TagTree"; last SWITCH; };
#         # what else could we look for?
#     }
    
    return $type;
}

#####################################################################
# aliases for naming consistency or other reasons                   #
#####################################################################

#*create = \&create_object;

}

# $Id: AnnotationFactory.pm 15407 2009-01-20 05:18:29Z cjfields $
#
# BioPerl module for Bio::Annotation::AnnotationFactory
#
# Cared for by Hilmar Lapp <hlapp at gmx.net>
#
# Copyright Hilmar Lapp
#
# You may distribute this module under the same terms as perl itself

#
# (c) Hilmar Lapp, hlapp at gmx.net, 2002.
# (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
#
# You may distribute this module under the same terms as perl itself.
# Refer to the Perl Artistic License (see the license accompanying this
# software package, or see http://www.perl.com/language/misc/Artistic.html)
# for the terms under which you may use, modify, and redistribute this module.
# 
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#

# POD documentation - main docs before the code

# =head1 NAME

# Bio::Annotation::AnnotationFactory - Instantiates a new 
# Bio::AnnotationI (or derived class) through a factory

# =head1 SYNOPSIS

#     use Bio::Annotation::AnnotationFactory;
#     # 
#     my $factory = Bio::Annotation::AnnotationFactory.new(
#                     type => 'Bio::Annotation::SimpleValue');
#     my $ann = $factory.create_object(value => 'peroxisome',
#                                       tagname => 'cellular component');


# =head1 DESCRIPTION

# This object will build L<Bio::AnnotationI> objects generically.

# =head1 FEEDBACK

# =head2 Mailing Lists

# User feedback is an integral part of the evolution of this and other
# Bioperl modules. Send your comments and suggestions preferably to
# the Bioperl mailing list.  Your participation is much appreciated.

#   bioperl-l@bioperl.org                  - General discussion
#   http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

# =head2 Reporting Bugs

# Report bugs to the Bioperl bug tracking system to help us keep track
# of the bugs and their resolution. Bug reports can be submitted via
# the web:

#   http://bugzilla.open-bio.org/

# =head1 AUTHOR - Hilmar Lapp

# Email hlapp at gmx.net


# =head1 CONTRIBUTORS

# This is mostly copy-and-paste with subsequent adaptation from
# Bio::Seq::SeqFactory by Jason Stajich. Most credits should in fact go
# to him.

# =head1 APPENDIX

# The rest of the documentation details each of the object methods.
# Internal methods are usually preceded with a _

# =cut




