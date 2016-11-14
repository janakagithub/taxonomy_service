package taxonomy_service::taxonomy_serviceClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

taxonomy_service::taxonomy_serviceClient

=head1 DESCRIPTION


A KBase module: taxonomy_service
This module serve as the taxonomy service in KBase.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => taxonomy_service::taxonomy_serviceClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 search_taxonomy

  $output = $obj->search_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is an int
	public has a value which is an int
	local has a value which is an int
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
	workspace has a value which is a string
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string
	parent has a value which is a string
	parent_ref has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is an int
	public has a value which is an int
	local has a value which is an int
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
	workspace has a value which is a string
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string
	parent has a value which is a string
	parent_ref has a value which is a string


=end text

=item Description



=back

=cut

 sub search_taxonomy
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function search_taxonomy (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to search_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'search_taxonomy');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "taxonomy_service.search_taxonomy",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'search_taxonomy',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method search_taxonomy",
					    status_line => $self->{client}->status_line,
					    method_name => 'search_taxonomy',
				       );
    }
}
 


=head2 create_taxonomy

  $output = $obj->create_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.CreateTaxonomyInputParams
$output is a taxonomy_service.CreateTaxonomyOut
CreateTaxonomyInputParams is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	parent has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	rank has a value which is a string
	comments has a value which is a string
	genetic_code has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	workspace has a value which is a string
CreateTaxonomyOut is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string
ObjectReference is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.CreateTaxonomyInputParams
$output is a taxonomy_service.CreateTaxonomyOut
CreateTaxonomyInputParams is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	parent has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	rank has a value which is a string
	comments has a value which is a string
	genetic_code has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	workspace has a value which is a string
CreateTaxonomyOut is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string
ObjectReference is a string


=end text

=item Description



=back

=cut

 sub create_taxonomy
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_taxonomy (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_taxonomy');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "taxonomy_service.create_taxonomy",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'create_taxonomy',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_taxonomy",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_taxonomy',
				       );
    }
}
 


=head2 get_taxonomies_by_id

  $output = $obj->get_taxonomies_by_id($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetTaxonomiesIdInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesIdInputParams is a reference to a hash where the following keys are defined:
	taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
ObjectReference is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon
Taxon is a reference to a hash where the following keys are defined:
	children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
	decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_lineage has a value which is a reference to a list where each element is a string
	decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
TaxonInfo is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.GetTaxonomiesIdInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesIdInputParams is a reference to a hash where the following keys are defined:
	taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
ObjectReference is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon
Taxon is a reference to a hash where the following keys are defined:
	children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
	decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_lineage has a value which is a reference to a list where each element is a string
	decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
TaxonInfo is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string


=end text

=item Description



=back

=cut

 sub get_taxonomies_by_id
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_taxonomies_by_id (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_taxonomies_by_id:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_taxonomies_by_id');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "taxonomy_service.get_taxonomies_by_id",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_taxonomies_by_id',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_taxonomies_by_id",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_taxonomies_by_id',
				       );
    }
}
 


=head2 change_taxa

  $output = $obj->change_taxa($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.ChangeTaxaInputParams
$output is a taxonomy_service.ChangeTaxaOut
ChangeTaxaInputParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	parent_taxa_ref has a value which is a string
ChangeTaxaOut is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	genome_name has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.ChangeTaxaInputParams
$output is a taxonomy_service.ChangeTaxaOut
ChangeTaxaInputParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	parent_taxa_ref has a value which is a string
ChangeTaxaOut is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	genome_name has a value which is a string


=end text

=item Description



=back

=cut

 sub change_taxa
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function change_taxa (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to change_taxa:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'change_taxa');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "taxonomy_service.change_taxa",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'change_taxa',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method change_taxa",
					    status_line => $self->{client}->status_line,
					    method_name => 'change_taxa',
				       );
    }
}
 


=head2 get_genomes_for_taxonomy

  $output = $obj->get_genomes_for_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetGenomesTaxonomyInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetGenomesTaxonomyInputParams is a reference to a hash where the following keys are defined:
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon
Taxon is a reference to a hash where the following keys are defined:
	children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
	decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_lineage has a value which is a reference to a list where each element is a string
	decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
ObjectReference is a string
TaxonInfo is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.GetGenomesTaxonomyInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetGenomesTaxonomyInputParams is a reference to a hash where the following keys are defined:
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon
Taxon is a reference to a hash where the following keys are defined:
	children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
	decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_lineage has a value which is a reference to a list where each element is a string
	decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
ObjectReference is a string
TaxonInfo is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string


=end text

=item Description



=back

=cut

 sub get_genomes_for_taxonomy
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_genomes_for_taxonomy (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_genomes_for_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_genomes_for_taxonomy');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "taxonomy_service.get_genomes_for_taxonomy",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_genomes_for_taxonomy',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_genomes_for_taxonomy",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_genomes_for_taxonomy',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "taxonomy_service.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "taxonomy_service.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_genomes_for_taxonomy',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_genomes_for_taxonomy",
            status_line => $self->{client}->status_line,
            method_name => 'get_genomes_for_taxonomy',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for taxonomy_service::taxonomy_serviceClient\n";
    }
    if ($sMajor == 0) {
        warn "taxonomy_service::taxonomy_serviceClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

A binary boolean


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ObjectReference

=over 4



=item Description

workspace ref to an object


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 DropDownItemInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
private has a value which is an int
public has a value which is an int
local has a value which is an int
search has a value which is a string
limit has a value which is an int
start has a value which is an int
workspace has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
private has a value which is an int
public has a value which is an int
local has a value which is an int
search has a value which is a string
limit has a value which is an int
start has a value which is an int
workspace has a value which is a string


=end text

=back



=head2 DropDownItem

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
label has a value which is a string
id has a value which is a string
category has a value which is a string
parent has a value which is a string
parent_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
label has a value which is a string
id has a value which is a string
category has a value which is a string
parent has a value which is a string
parent_ref has a value which is a string


=end text

=back



=head2 DropDownData

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
num_of_hits has a value which is an int
hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
num_of_hits has a value which is an int
hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem


=end text

=back



=head2 CreateTaxonomyInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
parent has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
rank has a value which is a string
comments has a value which is a string
genetic_code has a value which is a string
aliases has a value which is a reference to a list where each element is a string
workspace has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
parent has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
rank has a value which is a string
comments has a value which is a string
genetic_code has a value which is a string
aliases has a value which is a reference to a list where each element is a string
workspace has a value which is a string


=end text

=back



=head2 CreateTaxonomyOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string


=end text

=back



=head2 GetTaxonomiesIdInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference


=end text

=back



=head2 TaxonInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string


=end text

=back



=head2 Taxon

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_lineage has a value which is a reference to a list where each element is a string
decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_lineage has a value which is a reference to a list where each element is a string
decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string


=end text

=back



=head2 GetTaxonomiesOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxon_objects has a value which is a reference to a list where each element is a taxonomy_service.Taxon


=end text

=back



=head2 ChangeTaxaInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
parent_taxa_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
parent_taxa_ref has a value which is a string


=end text

=back



=head2 ChangeTaxaOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
genome_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
genome_name has a value which is a string


=end text

=back



=head2 GetGenomesTaxonomyInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
search has a value which is a string
limit has a value which is an int
start has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
search has a value which is a string
limit has a value which is an int
start has a value which is an int


=end text

=back



=cut

package taxonomy_service::taxonomy_serviceClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
