#!/usr/bin/perl -C64
#@ manjaro_bootable
use strict;
use warnings;
use v5.24;#5.20
use utf8;
# manjaro_bootable.pl Ver.0.8 alpha test. 2018-03-25,09-13
# (ubuntu/Mint)grub.cfg 上の manjaro/archlinux entry をブート可能にする。
# Only Run command on ubuntu/Mint.
# Kenkowo Nishihama live in Osaka,Japan.
#
# !! Best Practice!! You may install your bootloader at manjaro partation.
# And shall be given Happy, a little.
################################################

=cut

### pre_step 1 ### caution

use Getopt::Std;
my %opt;
getopts("V", \%opt);

unless (  exists $opt{V}  ) {
    say "Danger!! Run command with ROOT/Superuser privileges. \n  type.\n  sudo $0 -V" ;
    exit;
}

### check root's privileges.

my $user = getpwuid($>);
if ( $user !~ /root/ ){
    say "$user :: Not ROOT. ";
    exit;
}


### pre_step 2 ###
    `sudo cp  /boot/grub/grub.cfg /tmp/grub.cfg_original` ; #backup

    {
    local $/; #複数行を1行として扱う。ヌル。一括で読み込む。

    ### pre_step 2a ### check lsb-release.

    open(IN2,"/etc/lsb-release");
    while(<IN2>) {
        if ( m/manjaro|arch|antergos/i ){
            say "$&";
            exit;
        }
        elsif (    m/Mint|ubuntu/i  ) {
            say "$& is running. => go ahead." ; #distro type
        }
        else{
            say "Distro?! ";
            exit;
        } #
    }
    close(IN2);

    ### pre_step 2b ### check troubled lines.

    open(IN,"/tmp/grub.cfg_original");
    while (<IN>){
        if ( $_ =~  m{^\s+initrd /boot/intel-ucode.img$}sm ){
        say "found Target lines!!!! ";
        # next;
        }
        else{
        say "No Target lines! " and exit;
        }
        }
    close(IN);

    }

### step 1 ### main

my $tmpdir = '/tmp';
chdir $tmpdir;

my $TIMESTAMP=`date +%m%d_%H:%M` ; #現在時刻を変数にいれる。
`sudo cp  /boot/grub/grub.cfg /tmp/grub.cfg_original__$TIMESTAMP` ; #backup
#`sudo cp  /boot/grub/grub.cfg /boot/grub/grub.cfg_original` ; #backup

my $grubcfg="/boot/grub/grub.cfg";

#say "000! " and exit;
##### write 書き出しファイル
    my $outfile="/tmp/grub.cfg";
    open (OUT, ">$outfile") or die "$!";
##### read 読み込みファイル
    # my $infile="/boot/grub/grub.cfg_original";
    my $infile="/boot/grub/grub.cfg";
    open (IN, $infile) or die "$!";

while (<IN>) {

m|^\s+linux /boot/(vmlinuz-)(4\.\d\d-x86_64) root=UUID.*?rw quiet$| ; #
# m|\A\s+linux /boot/(vmlinuz-)(4\.\d\d-x86_64) root=UUID.*+rw quiet\z| ; #

my $kernelversion = $2 ;
my $ucode = "initrd /boot/intel-ucode.img";
            #main
#manjaro manjaro manjaro manjaro manjaro
    if ( m/^menuentry \'Manjaro Linux / .. m{^\s+$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_1|;# top main entry ::  print ;
        }
    elsif ( m/^submenu \'Advanced options for Manjaro Linux / .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_2|;# submenu main   print ;
        }
    elsif ( m/\s+menuentry \'Manjaro Linux.*?(?!fallback initramfs)/ .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_3|;# no fallback    print ;
        }
    elsif ( m/\s+menuentry \'Manjaro Linux.*?(?=fallback initramfs)/ .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_4|;# fallback    print ;
        }
    else{}
#antergos antergos antergos antergos antergos
    if ( m/^menuentry \'Antergos Linux\'/ .. m{^\s+$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_6|;# top main entry ::  print ;
        }
    # elsif ( m/^menuentry \'Antergos Linux \(on \/dev\/sd.\d\)\'/ .. m{^\s+$ucode$} )
    elsif ( m/^menuentry \QAntergos Linux \E.on .*?\d.\Q'\E/ .. m{^\s+$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_5|;#  for ubuntu
        }
    elsif ( m/^submenu \'Advanced options for Antergos Linux / .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_7|;# submenu main   print ;
        }
    elsif ( m/\s+menuentry \'Antergos Linux - Fallback/ .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_8|;# fallback    print ;
        }
    elsif ( m/\s+menuentry \'Antergos Linux LTS Kernel.*?(?!Fallback)/ .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_9|;# LTS no fallback    print ;
        }
    elsif ( m/\s+menuentry \'Antergos Linux LTS Kernel.*?(?=Fallback)/ .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_0|;# LTS fallback    print ;
        }
#Arch Linux Arch Linux Arch Linux Arch Linux Arch Linux
#on ubuntu for antergos
    elsif ( m/^submenu \'Advanced options for Arch Linux \(rolling\)/
    #\s+menuentry \'Antergos Linux LTS Kernel.*?(?=Fallback)/
     .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_5|;# LTS fallback    print ;
        }
    elsif ( m/\s+menuentry \'Antergos Linux / .. m{$ucode$} )
        { s|^(\s+)($ucode)$|$1$2 MissingTargetKernel_5|;# LTS fallback    print ;
        }
    else {
          s|^(\s+)($ucode)$|=========●=========NoWay $1$2|; #error
        }
### Step 3  ###パターン別最期の処理はまとめて
#manjaro

    s|MissingTargetKernel_1|/boot/initramfs-$kernelversion.img|;
    s|MissingTargetKernel_2|/boot/initramfs-$kernelversion.img|;
    s|MissingTargetKernel_3|/boot/initramfs-$kernelversion.img|;
    s|MissingTargetKernel_4|/boot/initramfs-$kernelversion-fallback.img|;
# #antergos/archlinux
    #_5 はantergosをubuntu 時に書き換えるモノ。対象は①行のみ。このあたりややこしいので、
    s|MissingTargetKernel_5|/boot/initramfs-linux.img|;              #^nuentry うまくいくかどうか、追加。
    s|MissingTargetKernel_6|/boot/initramfs-linux.img|;              #^menuentry
    s|MissingTargetKernel_7|/boot/initramfs-linux.img|;              #^\s+menuentry
    s|MissingTargetKernel_8|/boot/initramfs-linux-fallback.img|;
    s|MissingTargetKernel_9|/boot/initramfs-linux-lts.img|;           #LTS
    s|MissingTargetKernel_0|/boot/initramfs-linux-lts-fallback.img|;  #LTS Fallback

#print;         # check STDOUT 標準出力・冗長だが瞬間
print OUT $_;   # $outfile="/tmp/grub.cfg"  ファイルに書き出し

}

close (IN);
close (OUT);

### Step END ###

say "\t=== diff ===" ;

    system "sudo diff  $outfile $infile";  # diff new old
    system "sudo cp    $outfile $grubcfg"; # cp generated New grub.cfg

say "\t=== done ===" ;

### Dameoshi ###

    say "type GrubChk"; #


__END__

MEMO:
#system "sudo colordiff  $outfile ${grubcfg}_original || sudo diff --auto  $outfile ${grubcfg}_original";
#NG system "sudo colordiff  $outfile ${grubcfg}_original" || system "sudo diff  $outfile ${grubcfg}_original";

#system "GrubChk"; # check, kernel panic lines.
# permission #chmod 100444, $grubcfg ;