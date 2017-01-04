function test_fname(do_subjects, subjects, blocksin, blocksout, rawpathstem, pathstem, dates, badchannels)

for s=1:length(subjects)
    if class(subjects{s})=='char';
        subjects{s}.newname = subjects{s};
        subjects{s}.oldname = subjects{s}.newname;
    end
    subject{s} = { subjects{s}.newname dates{s} };
end

nr_sbj = length(subject);

try do_subjects,    % if do_subjects not defined, do all subjects
catch
    do_subjects = [1:nr_sbj];
end;

% Check file names and paths
checkflag = 0;
for ss = do_subjects,
    nr_bls = length( blocksin{ss} );
    if length(blocksin{ss}) ~= length(blocksout{ss}),
        checkflag = 1;
        fprintf(1, 'Different number of input and output names for subject %d (%s, %s)\n', ss, subject{ss}{1}, subject{ss}{2});
    end;
    for bb = 1:nr_bls,        
        try
            rawpath = fullfile( rawpathstem, subjects{ss}.oldname, subject{ss}{2} );
        catch
            rawpath = fullfile( rawpathstem, subject{ss}{1}, subject{ss}{2} );
        end
        rawfname = fullfile( rawpath, [blocksin{ss}{bb} '_raw.fif'] );
        if ~exist( rawfname, 'file' ) %Account for uneven naming convention in SD, which is awful!!
            if exist(fullfile( rawpath, [blocksin{ss}{bb}(2:end) '_raw.fif']), 'file' )
                rawfname = fullfile( rawpath, [blocksin{ss}{bb}(2:end) '_raw.fif'] );
            elseif exist(fullfile( rawpath, [blocksin{ss}{bb}(2:end) '.fif']), 'file' )
                rawfname = fullfile( rawpath, [blocksin{ss}{bb}(2:end) '.fif']);
            elseif exist(fullfile( rawpath, [blocksin{ss}{bb} '.fif']), 'file' )
                rawfname = fullfile( rawpath, [blocksin{ss}{bb} '.fif']);
            elseif strcmp(rawfname, '/megdata/cbu/cbp/meg08_0264/080520/0264_qway_raw.fif')
                rawfname = '/megdata/cbu/cbp/meg08_0264/080520/0264_qway_avg.fif';
            end
        end
        outpath = fullfile( pathstem, subject{ss}{1} );
        if ~exist( outpath, 'dir' ),
            success = mkdir( outpath );
            if ~success,
                checkflag = 1;
                fprintf(1, 'Could not create directory %s\n', outpath);
            end;
        end;
        if ~exist( rawfname, 'file' ),
            checkflag = 1;
            fprintf(1, '%s does not exist\n', rawfname);
        end;        
    end;
end;
if checkflag,
    fprintf(1, 'You''ve got some explaining to do.\n');
    return;
end;
