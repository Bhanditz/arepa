package Arepa;

our $VERSION = 0.70_01;
our $AREPA_MASTER_USER = 'arepa-master';

1;

__END__

=head1 NAME

Arepa - Apt REPository Assistant

=head1 DESCRIPTION

Arepa (Apt REPository Assistant) is a suite of tools to manage a Debian
package repository. It has the following features:

=over 4

=item

Manages the whole process after a package arrives to the upload queue (say,
after being uploaded by C<dput>): checking its signature, approving it,
re-building it from source, updating the repository and signing it, and
optionally sending the repository changes to another server (e.g. the
production static web server serving the repository).

=item

You approve source packages, which then are compiled to any combination of
architecture and distribution you want.

=item

Integration with several tools, including reprepro for repository maintenance
and sbuild for the autobuilders. You should not need to learn anything else
than Arepa commands to manage your repository.

=item

Web interface for package approval, compilation status and other tasks.

=back

=head1 INTRODUCTION

To use Arepa, you first must decide how you want your repositories to look
like, then configure Arepa to do what you want. The recommended way of
configuring Arepa is:

=over 4

=item

Decide which distributions you want

=item

Configure the reprepro repository

=item

Configure the web UI

=item

Create the necessary autobuilders

=back

Unfortunately, at this point there are a bunch of steps that aren't automated
yet. This will hopefully improve in the future.

Each of the sections below explain each point in detail:

=head2 DECIDE DISTRIBUTIONS

First of all, you have to know which distribution(s) you want to manage.
Typically, you would be interested in only one, maybe two. For the sake of the
example, let's assume you want to manage two distributions: one called
C<mysqueeze> and C<mylenny>. Each one of those will contain extra packages for
the Debian distributions "squeeze" and "lenny" (so they will have to be
compiled in those environments).

Once you have decided this, you also have to decide which aliases your
distributions will have. This is useful because incoming packages for those
alias distributions will work. For example, you probably want to accept
incoming source packages meant for C<unstable>, so you can say that
C<unstable> is an alias for C<mysqueeze>.

Now, there's another possibility that you might want: having a source package
compiled for B<several> distributions. This doesn't always work of course, but
it's useful in some cases. In this example, say that you want source packages
meant for C<unstable> compiled for both C<mysqueeze> and C<mylenny>. In that
case, you can say that C<unstable> is an alias for C<mysqueeze>, then say that
you want B<binNMUs> for all other distributions you want the package compiled
for.

Once you have the list of distributions, along with their aliases and possibly
binNMUs triggers, you can go ahead to the next section.

=head2 CONFIGURE REPOSITORY

Once you have a clear idea of the distributions you want, you have to
configure the reprepro repository. Open
C</var/arepa/repository/conf/distributions>. It will look something like this:

 Codename: squeeze
 Components: main
 Architectures: source amd64
 Suite: unstable

You need one of these stanzas for every distribution (separated by a blank
line). The C<Codename> should be the distribution name, and you can specify
the first alias as the C<Suite>. The rest of the aliases you can specify in a
field C<AlsoAcceptFor>, like so:

 Codename: mysqueeze
 Components: main
 Architectures: source amd64
 Suite: unstable
 AlsoAcceptFor: squeeze, stable

Now, make sure you have GPG key for the special user C<arepa-master>. That
will be the GPG key used to sign the repository. To do so, simply type:

 # su - arepa-master
 $ gpg --gen-key

And follow the instructions.

=head2 CONFIGURE WEB UI

The next step is to configure the web interface. Make sure that you can access
the application from the URL path C</arepa/arepa.cgi> and that it works
properly. If you have installed the Debian package, everything should be
already in place, and the only step you should follow is:

 # a2ensite arepa

Other steps you have to follow in any case:

=over 4

=item

Configure the users you want to access the application. Open
C</etc/arepa/users.yml> and add a line per user. The passwords should be
hashed with MD5. For example, you can use:

 echo -n "mypassword" | md5sum -

=item

Configure your C<sudo> so users in the group C<arepa> can execute
C</usr/bin/arepa-sign>.

=item

Add the keys of the developers that will upload packages to the keyring
C</var/arepa/keyrings/uploaders.gpg>

=back

Note that your upload queue is by default at C</var/arepa/upload-queue>, but
you can change it in the configuration file C</etc/arepa/config.yml>.

=head2 CREATE AUTOBUILDERS

Finally, you need to create an autobuilder for every combination of
distribution and architecture you want (in this case, let's say
C<mysqueeze>/C<amd64> and C<mylenny>/C<amd64>). Note that currently Arepa only
supports compiling for the same architecture, but theoretically you can
configure C<sbuild> manually to cross-compile for i386 in an amd64 environment
(see the C<personality> field in L<schroot(1)>).

To create an autobuilder, simply execute this command as root:

 arepa-admin createbuilder BUILDERDIR \
                           ftp://ftp.XX.debian.org/debian \
                           DISTRIBUTION

For example:

 arepa-admin createbuilder /var/chroot/squeezebuilder \
                           ftp://ftp.se.debian.org/debian \
                           squeeze

That will create a builder running Debian squeeze in
C</var/chroot/squeezebuilder>. Once it's ready, you might want to make sure
that the C</etc/apt/sources.list> is correct.
