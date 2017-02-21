use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use taxonomy_service::taxonomy_serviceImpl;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('taxonomy_service');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new Bio::KBase::workspace::Client($ws_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1);
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$taxonomy_service::taxonomy_serviceServer::CallContext = $ctx;
my $impl = new taxonomy_service::taxonomy_serviceImpl();

sub get_ws_name {
    if (!defined($ws_name)) {
        my $suffix = int(time * 1000);
        $ws_name = 'test_taxonomy_service_' . $suffix;
        $ws_client->create_workspace({workspace => $ws_name});
    }
    return $ws_name;
}

my $dropdown ={
    private => 0,
    public => 1,
    local => 0,
    #search => 'Klebsiella oxytoca str. M5al substr. janaka',
    #search => 'Bacillus subtilis subsp. subtilis str. JH642 substr. AG174',
    #search => 'janaka',
    search => 'Escher',
    limit => 10,
    start => 0,
    workspace => "janakakbase:1477671682968"

};
=head
ws_ref": "1292/406191/1",
        "parent_taxon_ref": "1292/146154/1"
        typical k.oxy substr M5a1 1292/505635/1
=cut

my $create_taxon_input = {
    scientific_name => "Klebsiella sp. janaka",
    parent => "1779/87821/1",
    genetic_code => "std_code",
    domain => "Bacteria",
    aliases => ["Klebsiella oxytoca str. janaka", "Klebsiella oxytoca strain janaka"],
    workspace => "janakakbase:1475159287939"
};

my $chagne_taxa_input = {
    input_genome => "Klebsiella_oxytoca_11492-1",
    scientific_name => "1779/590344/1",
    parent_taxa_ref => "1779/500276/1",
    workspace => "janakakbase:1477671682968",
    output_genome => "Klebsiella_oxytoca_modified_taxa"
};

my $genomes_by_taxa = {
    taxa_ref => '1779/590344/3'
};

my $get_genomes_for_taxa_group_params = {
    start => 10,
    limit => 20,
    lineage_step => 'Klebsiella'

};

eval {
   my $ret =$impl->search_taxonomy($dropdown);
   #my $ret =$impl->change_taxa($chagne_taxa_input);
   #my $ret =$impl->create_taxonomy($create_taxon_input);
   #my $ret =$impl->get_genomes_for_taxonomy($genomes_by_taxa);
   #my $ret = $impl->get_genomes_for_taxa_group($get_genomes_for_taxa_group_params);
};

my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
if (defined($err)) {
    if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
        die("Error while running tests: " . $err->trace->as_string);
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'taxonomy_service', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
}
