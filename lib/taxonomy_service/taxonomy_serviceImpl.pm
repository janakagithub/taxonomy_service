package taxonomy_service::taxonomy_serviceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org
our $VERSION = '0.0.1';
our $GIT_URL = '';
our $GIT_COMMIT_HASH = '';

=head1 NAME

taxonomy_service

=head1 DESCRIPTION

A KBase module: taxonomy_service
This module serve as the taxonomy service in KBase.

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Data::Dumper;
use POSIX;
use FindBin qw($Bin);
use JSON;
use LWP::UserAgent;
use XML::Simple;
use WebService::Solr;
use WebService::Solr::Query;



sub _parseResponse
{
    my ($self, $response, $responseType) = @_;

    # Clear the error fields
    $self->{is_error} = 0;
    $self->{error} = undef;

    $responseType = "xml" unless $responseType;

    # Check for successfull request/response
    if ($response->{responsecode} eq "200") {
           if ($responseType eq "json") {
                my $resRef = JSON::from_json($response);
                if ($resRef->{responseHeader}->{status} eq 0) {
                        return 1;
                }
            } else {
                my $xs = new XML::Simple();
                my $xmlRef;
                eval {
                        $xmlRef = $xs->XMLin($response);
                };
                if ($xmlRef->{lst}->{'int'}->{status}->{content} eq 0){
                        return 1;
                }
            }
    }
    $self->{is_error} = 1;
    $self->{error} = $response;
    $self->{error}->{errmsg} = $@;
    return 0;
}


#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('taxonomy_service','workspace-url');
    die "no workspace-url defined" unless $wsInstance;

    $self->{'workspace-url'} = $wsInstance;

    #SOLR specific parameters
    if (! $self->{_SOLR_URL}) {
        $self->{_SOLR_URL} = "http://kbase.us/internal/solr-ci/search";
    }
    $self->{_SOLR_POST_URL} = $self->{_SOLR_URL};
    $self->{_SOLR_PING_URL} = "$self->{_SOLR_URL}/select";
    $self->{_AUTOCOMMIT} = 0;
    $self->{_CT_XML} = { Content_Type => 'text/xml; charset=utf-8' };
	$self->{_CT_JSON} = { Content_Type => 'text/json'};

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 search_taxonomy

  $output = $obj->search_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is a taxonomy_service.bool
	public has a value which is a taxonomy_service.bool
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
bool is an int
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is a taxonomy_service.bool
	public has a value which is a taxonomy_service.bool
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
bool is an int
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string


=end text



=item Description



=back

=cut

sub search_taxonomy
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to search_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN search_taxonomy
    my $url =$self->{_SOLR_URL}."/QZtest/select?q=*:*";


	my $query = WebService::Solr::Query->new( { workspace_name => 'KBasePublicRichGenomesV5' } );
    my %options = (
        fq => [
            WebService::Solr::Query->new( { genome_source => 'KBase Central Store' } ),
            WebService::Solr::Query->new( { taxonomy => 'Bacteria' } ),
        ],
    );
    #print &Dumper ($response);

    open INFILE, "/kb/module/data/orglist.txt" or die "Couldn't open html file $!\n";

    my %sHash;
    while (defined(my $input = <INFILE>)){
        chomp $input;
        #print "*$input*\n";
        $sHash{$input} = 1;
    }

    #for (grep /\b\Q$some_word\E\b/, keys %sHash)
    my @searchHits;
    my $count =0;
    for (grep /$params->{search}/, keys %sHash){
     	my $orgArr = {
        	label => $_,
        	id => "somews",
        	category => "some category"
       	};
     	push (@searchHits, $orgArr);
     	if ($count >= $params->{limit}){
     		last;
     	}
     	$count++;
	}

	my $arLen = @searchHits;
    print "$arLen\n";

##############################################Testing code for querying solr############################
=head
my $searchCore = "QZtest";
my $groupOption = "";
my $searchParams = {
		fl => "*",
		wt => "json",
		rows => 101,
		sort => "genome_id asc",
		hl => "false",
		start => 0
	};
	my $searchQuery = { q => "*" };


my $skipEscape = {} ;

	# If output format is not passed set it to XML
    my $resultFormat = "xml";
    my $DEFAULT_FIELD_CONNECTOR = "AND";

	# Build the queryFields string with $searchQuery and $searchParams
	my $queryFields = "";
    if (! $searchQuery) {
        $self->{is_error} = 1;
        $self->{errmsg} = "Query parameters not specified";
        return undef;
    }
	foreach my $key (keys %$searchParams) {
        $queryFields .= "$key=". URI::Escape::uri_escape($searchParams->{$key}) . "&";

        #print &Dumper ($queryFields);
        #print "\n\n";
    }

	my $qStr = "q=";
    if (defined $searchQuery->{q}) {
        $qStr .= URI::Escape::uri_escape($searchQuery->{q});
       # print "$qStr\n\n";

    }

    $queryFields .= "$qStr";

	my $solrCore = "/$searchCore";
  	my $sort = "&sort=genome_id asc";
	my $solrGroup = $groupOption ? "&group=true&group.field=$groupOption" : "";
	my $solrQuery = $self->{_SOLR_URL}.$solrCore."/select?".$queryFields.$solrGroup;
	#print "Query string:\n$solrQuery\n";

##########

#=cut
    my ($url, $method, $dataType, $headers, $data);
  # Intialize the request params if not specified
     $dataType = ($dataType) ? $dataType : 'text';
     $method = ($method) ? $method : 'GET';
     #$url = $self->{_SOLR_URL}."/QZtest/select?q=*:*";
     $url = $self->{_SOLR_URL}."/taxonomy/select?q=*%3A*&start=0&rows=10000&fl=scientific_name&wt=json&indent=true";
     $headers = ($headers) ?  $headers : {};
     $data = ($data) ? $data: '';

    my $out = {};

    my $header_field = {
    	scientific_name => "Wolbachia phage WOcauB1"

    };
    #print &Dumper ($self);
    #die;
    # create a HTTP request
    my $ua = LWP::UserAgent->new();
    my $request = HTTP::Request->new();
    $request->method($method);
    $request->uri($url);



    # set headers
    foreach my $header (keys %$headers) {
        $request->header($header =>  $headers->{$header});
    }

    # set data for posting
    #$request->content($data);
	#print "The HTTP request: \n" . Dumper($request) . "\n";

    # Send request and receive the response
    my $response = $ua->request($request);
    #my $r = solr->generic_solr_request( $url, $query );
    #my $response = $solr->search($request);


    my $sn = $response->content();
    my $code = $response->code();
    my $header = $response->header($header_field);

    #print "$sn\n";
    my $outjson = JSON::from_json($sn);
    #my $json_text = JSON->new->utf8->decode($sn);
    #print &Dumper ($outjson);
    #print &Dumper ($response->{response});
    #my $outjson = JSON::from_json($response);
	#my $responseCode = _parseResponse($response, "json");

    	if ($responseCode) {
        	if ($resultFormat eq "json") {
            	#my $outjson = JSON::from_json($response);

        	}
	}


    $out->{responsecode} = $response->code();
    $out->{response} = $response->content;
    $out->{url} = $url;
=cut
####################################################Testing code for querying solr###############################

    $output = {
    	num_of_hits => $arLen,
    	hits =>  \@searchHits
    };

     print &Dumper ($output);
    return $output;

    #END search_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to search_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_taxonomy');
    }
    return($output);
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
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	workspace_name has a value which is a string
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
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	aliases has a value which is a reference to a list where each element is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	workspace_name has a value which is a string
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to create_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'create_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN create_taxonomy
    #END create_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to create_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'create_taxonomy');
    }
    return($output);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_taxonomies_by_id:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_id');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_taxonomies_by_id
    #END get_taxonomies_by_id
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_taxonomies_by_id:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_id');
    }
    return($output);
}




=head2 get_taxonomies_by_query

  $output = $obj->get_taxonomies_by_query($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetTaxonomiesQueryInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesQueryInputParams is a reference to a hash where the following keys are defined:
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

$params is a taxonomy_service.GetTaxonomiesQueryInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesQueryInputParams is a reference to a hash where the following keys are defined:
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

sub get_taxonomies_by_query
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_taxonomies_by_query:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_query');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_taxonomies_by_query



    #END get_taxonomies_by_query
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_taxonomies_by_query:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_query');
    }
    return($output);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_genomes_for_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_genomes_for_taxonomy


    #END get_genomes_for_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_genomes_for_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxonomy');
    }
    return($output);
}




=head2 status

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
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
private has a value which is a taxonomy_service.bool
public has a value which is a taxonomy_service.bool
search has a value which is a string
limit has a value which is an int
start has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
private has a value which is a taxonomy_service.bool
public has a value which is a taxonomy_service.bool
search has a value which is a string
limit has a value which is an int
start has a value which is an int


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

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
label has a value which is a string
id has a value which is a string
category has a value which is a string


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
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string
scientific_lineage has a value which is a reference to a list where each element is a string
workspace_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string
scientific_lineage has a value which is a reference to a list where each element is a string
workspace_name has a value which is a string


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



=head2 GetTaxonomiesQueryInputParams

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

1;
