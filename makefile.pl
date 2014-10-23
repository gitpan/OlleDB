#---------------------------------------------------------------------
# $Header: /Perl/OlleDB/makefile.pl 6     05-11-13 16:32 Sommar $
#
# Makefile.pl for MSSQL::OlleDB. Note that you may need to specify where
# you ave the include files for OLE DB.
#
# $History: makefile.pl $
# 
# *****************  Version 6  *****************
# User: Sommar       Date: 05-11-13   Time: 16:32
# Updated in $/Perl/OlleDB
# Use /O2 for optimization.
#
# *****************  Version 5  *****************
# User: Sommar       Date: 05-07-03   Time: 23:41
# Updated in $/Perl/OlleDB
# Now we use SQLNCLI.H, which means that we will have to move away from
# VC6.
#
# *****************  Version 4  *****************
# User: Sommar       Date: 04-08-23   Time: 22:49
# Updated in $/Perl/OlleDB
#
# *****************  Version 3  *****************
# User: Sommar       Date: 04-08-23   Time: 21:52
# Updated in $/Perl/OlleDB
#
# *****************  Version 2  *****************
# User: Sommar       Date: 04-04-27   Time: 22:32
# Updated in $/Perl/MSSQL/OlleDB
#
# *****************  Version 1  *****************
# User: Sommar       Date: 04-03-18   Time: 20:24
# Created in $/Perl/MSSQL/OlleDB
#---------------------------------------------------------------------


use strict;

my $SQLDIR;

use ExtUtils::MakeMaker;

# Run CL to see if we are running some version of the Visual C++ compiler.
my $cl = `cl 2>&1`;
my $clversion = 0;
if ($cl =~ m!^Microsoft.*C/C\+\+\s+Optimizing\s+Compiler\s+Version\s+(\d+)!i) {
   $clversion = $1;
}

if ($clversion == 0) {
   warn "You don't appear to have Visual C++ installed. If you use another\n";
   warn "C++ compiler, I have no idea whether that will work or not. Be warned!\n";
}
elsif ($clversion < 13) {
   warn "You are using Visual C++ 6.0 or earlier. Unfortunately, OlleDB.xs\n";
   warn "performs an #include of SQLNCLI.H which does not compile with VC6.\n";
   die  "No MAKEFILE generated.\n";
}

my $SQLDIR  = 'C:\Program Files\Microsoft SQL Server\90\SDK';
my $sqlnclih = "$SQLDIR\\INCLUDE\\SQLNCLI.H";
if (not -r $sqlnclih) {
    warn "Can't read '$sqlnclih'..\n";
    warn 'Check setting of $SQLDIR in makefile.pl' . "\n";
    die  "No MAKEFILE generated.\n";
}



WriteMakefile(
    'INC'          => ($SQLDIR ? qq!-I"$SQLDIR\\INCLUDE"! : ""),
    'NAME'         => 'MSSQL::OlleDB',
#    'CCFLAGS'      => '/P',
    'OPTIMIZE'     => '/O2',
    'VERSION_FROM' => 'OlleDB.pm',
    'XS'           => { 'OlleDB.xs' => 'OlleDB.cpp' },
    'dynamic_lib'  => { OTHERLDFLAGS => '/base:"0x19860000"'}
    # Set base address to avoid DLL collision, makes startup speedier. Remove
    # if your compiler don't have this option.
);

sub MY::xs_c {
    '
.xs.cpp:
   $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) $(XSUBPP) $(XSPROTOARG) $(XSUBPPARGS) $*.xs >xstmp.c && $(MV) xstmp.c $*.cpp
';
}

