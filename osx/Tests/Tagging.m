//
//  Tagging.m
//  
//
//  Created by waker on 26/04/16.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#include "playlist.h"
#include "junklib.h"
#include "vfs.h"
#include "plugins.h"
#include "conf.h"
#include "../../common.h"
#include "dummy_mp3.c"

#define TESTFILE "/tmp/testfile.mp3"

static int
write_file_from_data(const char *filename, const char *data, size_t size) {
    FILE *fp = fopen (filename, "w+b");
    if (!fp) {
        return -1;
    }

    int res = (size == fwrite (data, 1, size, fp)) ? 0 : -1;

    fclose (fp);
    return res;
}


@interface Tagging : XCTestCase {
    playItem_t *it;
}

@end

@implementation Tagging

- (void)setUp {
    [super setUp];

    write_file_from_data(TESTFILE, mp3_file_data, sizeof (mp3_file_data));

    NSString *resPath = [[NSBundle bundleForClass:[self class]] resourcePath];
    const char *str = [resPath UTF8String];
    strcpy (dbplugindir, str);

    conf_init ();
    conf_enable_saving (0);

    pl_init ();
    if (plug_load_all ()) { // required to add files to playlist from commandline
        exit (-1);
    }

    it = pl_item_alloc_init (TESTFILE, "stdmpg");
}

- (void)tearDown {
    pl_item_unref (it);

    plug_disconnect_all ();
    plug_unload_all ();
    pl_free ();
    conf_free ();

    unlink (TESTFILE);

    [super tearDown];
}

- (void)test_loadTags_DoesntCrash {
    DB_FILE *fp = vfs_fopen (TESTFILE);
    junk_id3v2_read (it, fp);
    vfs_fclose (fp);
}

@end
