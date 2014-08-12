use ExtUtils::MakeMaker;

my $MSGFMT = 'msgfmt';

print "Portable message objects...";
if ($MSGFMT =~ /./ && $MSGFMT ne "no") {
   $alltarget = "update-gmo";
   for (<./share/po/*.po>) {
      my ($po) = /.\/share\/po\/(.*)\.po$/;
      print " $po";
      $install .= "\t\$(MKPATH) \$(datadir)/locale/$po/LC_MESSAGES\n".
                  "\t\$(CP) $po.gmo \$(datadir)/locale/$po/LC_MESSAGES/perl-DateLocale.mo\n".
                  "\t\$(CHMOD) 644 \$(datadir)/locale/$po/LC_MESSAGES/perl-DateLocale.mo\n";
      $uninstall .= "	\$(RM_F) \$(datadir)/locale/$po/LC_MESSAGES/perl-DateLocale.mo\n";
      $mofiles   .= " $po.gmo";
   }
} else {
   $alltarget = "";
   print " skipped";
}
print "\n";

WriteMakefile(
    NAME              => 'DateLocale',
    VERSION_FROM      => 'lib/DateLocale.pm', # finds $VERSION
#	MAN3PODS          => {
#		'lib/AnyEvent/Net/SafeBrowsing2.pm'           => 'blib/man3/AnyEvent::Net::SafeBrowsing2.3',
#		'lib/AnyEvent/Net/SafeBrowsing2/Tarantool.pm' => 'blib/man3/AnyEvent::Net::SafeBrowsing2::Tarantool.3',
#	},
    PREREQ_PM         => {
		Locale::Messages => 0,
		POSIX            => 0,
	},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (AUTHOR         => 'Nikolay Shulyakovskiy <shulyakovskiy@mail.ru>') : ()),
);

sub MY::postamble {
   <<XXX
prefix = $prefix
datadir  = $datadir

%.gmo: %.po
	$MSGFMT -o \$*.gmo share/po/\$*.po
	\$(MKPATH) blib/lib/DateLocale/share/locale/\$*/LC_MESSAGES
	\$(CP) \$*.gmo blib/lib/DateLocale/share/locale/\$*/LC_MESSAGES/perl-DateLocale.mo
	\$(CHMOD) 644 blib/lib/DateLocale/share/locale/\$*/LC_MESSAGES/perl-DateLocale.mo

%.po: perl-DateLocale.pot
	-msgmerge -w 83 share/po/\$*.po perl-DateLocale.pot >\$*.po~
	-if cmp -s \$*.po~ \$*.po; then rm -f \$*.po~ ; else mv \$*.po~ \$*.po; fi

all :: $alltarget

update-gmo: $mofiles
	\$(RM_F) perl-DateLocale.pot
	\$(RM_F) *.gmo

update-po: update-pot

perl-DateLocale.pot: update-pot

update-pot: force
	xgettext --from-code="UTF-8" `find . -type f -print | grep \'\\.pm\$\$\'` -o perl-DateLocale.pot
	#if cmp -s perl-DateLocale.pot~ perl-DateLocale.pot; then rm -f perl-DateLocale.pot~ ; else mv perl-DateLocale.pot~ perl-DateLocale.pot; fi

force:


uninstall :: uninstall-po




uninstall-po ::
$uninstall

clean ::
	test -f Makefile || mv -f Makefile.old Makefile
XXX
}




#install :: install-po
#$install