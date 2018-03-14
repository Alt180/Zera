package Zera::Base::View;

use JSON;

use Zera::Conf;
use Zera::Com;
use Zera::Form;
use Zera::List;
use Zera::LayoutAdmin;

# Base functions
sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;
    
    # Main Zera object
    $self->{Zera} = shift;
    $self->{dbh} = $self->{Zera}->{_DBH}->{_dbh};
    $self->{sess} = $self->{Zera}->{_SESS}->{_sess};
    
    # Init app ENV
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
}

sub set_title {
    my $self = shift;
    my $title = shift;
    $self->{Zera}->{_PAGE}->{title} = $title;
}

sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
}

sub param {
    my $self = shift;
    my $var = shift;
    my $val = shift;
    if(defined $val){
        $self->{Zera}->{_REQUEST}->param($var,$val);
    }else{
        return $self->{Zera}->{_REQUEST}->param($var);
    }
}

sub get_view {
    my $self = shift;
    my $sub_name = $self->param('View');
    $sub_name = "display_" . lc($sub_name);
    if ($self->can($sub_name) ) {
        $self->{Zera}->{sub_name} = $sub_name;
        return $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
        return $self->{Zera}->get_msg();
    }
}

sub get_default_view {
    my $self = shift;
    my $sub_name = 'display_home';
    if ($self->can($sub_name) ) {
        $self->{Zera}->{sub_name} = $sub_name;
        return $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
        return $self->{Zera}->get_msg();
    }
}

sub form {
    my $self = shift;
    my $params = shift;
    return Zera::Form->new($self->{Zera}, $params);
}

sub sess {
    my $self = shift;
    my $name = shift;
    my $value = shift;
    
    if(defined $value){
        $self->{Zera}->{_SESS}->{_sess}{$name} = "$value";
    }else{
        return $self->{Zera}->{_SESS}->{_sess}{$name};
    }
}

sub render_template {
    my $self = shift;
    my $vars = shift;
    my $template = shift || $self->{Zera}->{sub_name};
    my $HTML = '';

    if(-e ('Zera/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/tmpl/' . $template . '.html')){
        $template = 'Zera/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/tmpl/' . $template . '.html';
    }elsif(-e ('templates/' . $conf->{Template}->{TemplateID} . '/' . $template . '.html')){
        $template = 'templates/' . $conf->{Template}->{TemplateID} . '/' . $template . '.html';
    }else{
        $self->add_msg('danger','Template ' . $template . ' not found.');
        return $self->{Zera}->get_msg();
    }
    
    
    $vars->{conf} = $conf;
    $vars->{msg}  = $self->{Zera}->get_msg();
    $vars->{page} = $self->{Zera}->{_PAGE};
    
    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR \n";
    return $HTML;
}

sub _tag {
    my $self     = shift;
    my $tag_type = shift;
    my $attrs    = shift;
    my $content  = shift;

    my $tag = '';
    foreach my $key (keys %{$attrs}){
        $tag .= ' ' . $key .'="'. $attrs->{$key}.'"';
    }
    if($content){
        return '<' . $tag_type . $tag . '>' . $content . '</' . $tag_type . '>';
    }else{
        return '<' . $tag_type . $tag . ' />';
    }
}

sub display_msg {
    my $self = shift;

    my $vars = {
    };
    return $self->render_template($vars,'msg-admin');
}

sub add_jsfile {
    my $self = shift;
    my $js_file = shift;
    if(-e ('Zera/' . $self->{Zera}->{ControllerName} . '/js/' . $js_file . '.js')){
        $self->{Zera}->{_PAGE}->{js_files} .= '<script src="' . '/Zera/' . $self->{Zera}->{ControllerName} . '/js/' . $js_file . '.js' . '"></script>';
    }else{
        $self->add_msg('danger',"JS file $js_file does not exist.");
    }
}

1;