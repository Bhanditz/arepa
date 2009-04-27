use strict;
use warnings;

use Test::More tests => 11;
use Arepa::PackageDb;

use constant TEST_DATABASE => 't/source_packages_test.db';

unlink TEST_DATABASE;
my $pdb = Arepa::PackageDb->new(TEST_DATABASE);
my %attrs = (name         => 'dhelp',
             full_version => '0.6.18',
             architecture => 'all',
             distribution => 'unstable');
my $id = $pdb->insert_source_package(%attrs);
my $id2 = $pdb->get_source_package_id($attrs{name}, $attrs{full_version});
is($id2, $id,
   "get_source_package_id should return the correct id");
my %attrs_from_db = $pdb->get_source_package_by_id($id);
foreach my $attr (qw(name full_version architecture distribution)) {
    is($attrs_from_db{$attr}, $attrs{$attr},
       "Attribute '$attr' should be '$attrs{$attr}' " .
            "(was '$attrs_from_db{$attr}')");
}



my %new_attrs = (name         => 'dhelp',
                 full_version => '0.6.18.1',
                 architecture => 'any',
                 distribution => 'lenny');
my $new_id = $pdb->insert_source_package(%new_attrs);
my $new_id2 = $pdb->get_source_package_id($new_attrs{name},
                                          $new_attrs{full_version});
is($new_id2, $new_id,
   "get_source_package_id should return the correct id (2)");
my %new_attrs_from_db = $pdb->get_source_package_by_id($new_id);
foreach my $attr (qw(name full_version architecture distribution)) {
    is($new_attrs_from_db{$attr}, $new_attrs{$attr},
       "Attribute '$attr' should be '$new_attrs{$attr}' " .
            "(was '$new_attrs_from_db{$attr}')");
}


my $invalid_id_fails = 1;
eval {
    $pdb->get_source_package_by_id(666),
    $invalid_id_fails = 0;
};
is($invalid_id_fails, 1,
   "Asking for a source package with an invalid id should fail");
