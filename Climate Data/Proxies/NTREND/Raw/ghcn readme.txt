GLOBAL HISTORICAL CLIMATOLOGY NETWORK MONTHLY (GHCNM) Version 3
(Last Updated: 11/17/2015)

1. INTRODUCTION

    1.1 OVERVIEW

        The GHCNM v3 has been released.  This version currently contains 
        monthly mean temperature, monthly maximum temperature and
        monthly minimum temperature.  The station network for the time being,
        is the same as GHCN-Monthly version 2 (7280 stations).  A new 
        software processing system is now responsible for daily reprocessing
        of the dataset. This reprocessing consists of a construction process
        that assembles the data in a specific source priority order, quality
        controls the data, identifies inhomogeneities and performs adjustments
        where possible. In addition, graphical products, including individual
        station time series plots are produced daily.

        V3 contains two different dataset files per each of the three elements.
        "QCU" files represent the quality controlled unadjusted data, and 
        "QCA" files represent the quality controlled adjusted data. The unadjusted 
        data are often referred to as the "raw" data. It is important to note that
        the term "unadjusted" means that the developers of GHCNM have not made any
        adjustments to these received and/or collected data, but it is entirely 
        possible that the source of these data (generally National Meteorological 
        Services) may have made adjustments to these data prior to their inclusion
        within the GHCNM.  Often it is difficult or impossible to know for sure,
        if these original sources have made adjustments, so users who desire 
        truly "raw" data would need to directly contact the data source.
        The "adjusted" data contain bias corrected data (e.g. adjustments made
        by the developers of GHCNM), and so these data can differ from the 
        "unadjusted" data.

    1.2 INTERNET ACCESS

        The GHCNM v3 has two primary locations:

        WEB: http://www.ncdc.noaa.gov/ghcnm

        FTP: ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/v3

    1.3 DOWNLOADING AND INSTALLING

        WINDOWS (example):

	GHCNM files are compressed into gzip format.  For more information on gzip, 
        please see the following web site:

        www.gzip.org

        and for potential software that can compress/decompress gzip files, please see:

        www.gzip.org/#faq4


        LINUX (example):

        wget ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/v3/ghcnm.latest.qcu.tar.gz
        tar -zxvf ghcnm.latest.qcu.tar.gz

        (alternatively, if "tar" does not support decompression, a user can try:

        wget ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/v3/ghcnm.latest.qcu.tar.gz
        gzip -d ghcnm.latest.qcu.tar.gz
        tar -xvf ghcnm.latest.qcu.tar.gz)


        Note: the data are placed in their own separate directory, that is named
              according to the following specification:

              ghcnm.v3.x.y.YYYYMMDD where 

              x = integer to be incremented with major data additions 
              y = integer to be incremented with minor data additions
              YYYY = year specific dataset was processed and produced
              MM   = month specific dataset was processed and produced
              DD   = day specific dataset was processed and produced
 
              Two files (per element) should be present in the directory a 
              1) metadata and 2) data file. Note: there will be no 
              increments to "x" and "y" above during the phase.

2. DATA

    2.1 METADATA

       The metadata has been carried over from GHCN-Monthly v2.  This would 
       include basic geographical station information such as latitude, 
       longitude, elevation, station name, etc., and also extended metadata
       information, such as surrounding vegetation, etc.

    2.1.1 METADATA FORMAT

       Variable          Columns      Type
       --------          -------      ----

       ID                 1-11        Integer
       LATITUDE          13-20        Real
       LONGITUDE         22-30        Real
       STNELEV           32-37        Real
       NAME              39-68        Character
       GRELEV            70-73        Integer
       POPCLS            74-74        Character
       POPSIZ            75-79        Integer
       TOPO              80-81        Character
       STVEG             82-83        Character
       STLOC             84-85        Character
       OCNDIS            86-87        Integer
       AIRSTN            88-88        Character
       TOWNDIS           89-90        Integer
       GRVEG             91-106       Character
       POPCSS            107-107      Character

       Variable Definitions:

       ID: 11 digit identifier, digits 1-3=Country Code, digits 4-8 represent
           the WMO id if the station is a WMO station.  It is a WMO station if
           digits 9-11="000".

       LATITUDE: latitude of station in decimal degrees

       LONGITUDE: longitude of station in decimal degrees

       STELEV: is the station elevation in meters. -999.0 = missing.

       NAME: station name

       GRELEV: station elevation in meters estimated from gridded digital
               terrain data

       POPCLS: population class 
               (U=Urban (>50,000 persons); 
               (S=Suburban (>=10,000 and <= 50,000 persons);
               (R=Rural (<10,000 persons)
               City and town boundaries are determined from location of station
               on Operational Navigation Charts with a scale of 1 to 1,000,000.
               For cities > 100,000 persons, population data were provided by
               the United Nations Demographic Yearbook. For smaller cities and
               towns several atlases were uses to determine population.

       POPSIZ: the population of the city or town the station is location in
               (expressed in thousands of persons).

       TOPO: type of topography in the environment surrounding the station,
             (Flat-FL,Hilly-HI,Mountain Top-MT,Mountainous Valley-MV).

       STVEG: type of vegetation in environment of station if station is Rural
              and when it is indicated on the Operational Navigation Chart
              (Desert-DE,Forested-FO,Ice-IC,Marsh-MA).

       STLOC: indicates whether station is near lake or ocean (<= 30 km of 
              ocean-CO, adjacent to a lake at least 25 square km-LA).

       OCNDIS: distance to nearest ocean/lake from station (km).
 
       AIRSTN: airport station indicator (A=station at an airport).

       TOWNDIS: distance from airport to center of associated city or town (km).

       GRVEG: vegetation type at nearest 0.5 deg x 0.5 deg gridded data point of
              vegetation dataset (44 total classifications).

              BOGS, BOG WOODS
              COASTAL EDGES
              COLD IRRIGATED
              COOL CONIFER
              COOL CROPS
              COOL DESERT
              COOL FIELD/WOODS
              COOL FOR./FIELD
              COOL GRASS/SHRUB
              COOL IRRIGATED
              COOL MIXED
              EQ. EVERGREEN
              E. SOUTH. TAIGA
              HEATHS, MOORS
              HIGHLAND SHRUB
              HOT DESERT
              ICE
              LOW SCRUB
              MAIN TAIGA
              MARSH, SWAMP
              MED. GRAZING
              NORTH. TAIGA
              PADDYLANDS
              POLAR DESERT
              SAND DESERT
              SEMIARID WOODS
              SIBERIAN PARKS
              SOUTH. TAIGA
              SUCCULENT THORNS
              TROPICAL DRY FOR
              TROP. MONTANE
              TROP. SAVANNA
              TROP. SEASONAL
              TUNDRA
              WARM CONIFER
              WARM CROPS
              WARM DECIDUOUS
              WARM FIELD WOODS
              WARM FOR./FIELD
              WARM GRASS/SHRUB
              WARM IRRIGATED
              WARM MIXED
              WATER
              WOODED TUNDRA

       POPCSS: population class as determined by Satellite night lights 
               (C=Urban, B=Suburban, A=Rural)

    2.2  DATA 

         The data within GHCNM v3 for the time being consist of monthly
         average temperature, and maximum and minimum temperature, for the 
         7280 stations contained within GHCNM v2. Several new sources have 
         been added to v3, and a new "3 flag" format has been introduced, 
         similar to that used within the Global Historical Climatology 
         Network-Daily (GHCND).

    2.2.1 DATA FORMAT

          Variable          Columns      Type
          --------          -------      ----

          ID                 1-11        Integer
          YEAR              12-15        Integer
          ELEMENT           16-19        Character
          VALUE1            20-24        Integer
          DMFLAG1           25-25        Character
          QCFLAG1           26-26        Character
          DSFLAG1           27-27        Character
            .                 .             .
            .                 .             .
            .                 .             .
          VALUE12          108-112       Integer
          DMFLAG12         113-113       Character
          QCFLAG12         114-114       Character
          DSFLAG12         115-115       Character

          Variable Definitions:

          ID: 11 digit identifier, digits 1-3=Country Code, digits 4-8 represent
              the WMO id if the station is a WMO station.  It is a WMO station if
              digits 9-11="000".

          YEAR: 4 digit year of the station record.
 
          ELEMENT: element type, monthly mean temperature="TAVG"
                                 monthly maximum temperature="TMAX"
                                 monthly minimum temperature="TMIN"

          VALUE: monthly value (MISSING=-9999).  Temperature values are in
                 hundredths of a degree Celsius, but are expressed as whole
                 integers (e.g. divide by 100.0 to get whole degrees Celsius).

          DMFLAG: data measurement flag, nine possible values:

                  blank = no measurement information applicable
                  a-i = number of days missing in calculation of monthly mean
                        temperature (currently only applies to the 1218 USHCN
                        V2 stations included within GHCNM)

          QCFLAG: quality control flag, seven possibilities within
                  quality controlled unadjusted (qcu) dataset, and 2 
                  possibilities within the quality controlled adjusted (qca) 
                  dataset.

                  Quality Controlled Unadjusted (QCU) QC Flags:
         
                  BLANK = no failure of quality control check or could not be
                          evaluated.

                  D = monthly value is part of an annual series of values that
                      are exactly the same (e.g. duplicated) within another
                      year in the station's record.

                  I = checks for internal consistency between TMAX and TMIN. 
                      Flag is set when TMIN > TMAX for a given month. 

                  L = monthly value is isolated in time within the station
                      record, and this is defined by having no immediate non-
                      missing values 18 months on either side of the value.

                  M = Manually flagged as erroneous.

                  O = monthly value that is >= 5 bi-weight standard deviations
                      from the bi-weight mean.  Bi-weight statistics are
                      calculated from a series of all non-missing values in 
                      the station's record for that particular month.

                  S = monthly value has failed spatial consistency check.
                      Any value found to be between 2.5 and 5.0 bi-weight
                      standard deviations from the bi-weight mean, is more
                      closely scrutinized by exmaining the 5 closest neighbors
                      (not to exceed 500.0 km) and determine their associated
                      distribution of respective z-scores.  At least one of 
                      the neighbor stations must have a z score with the same
                      sign as the target and its z-score must be greater than
                      or equal to the z-score listed in column B (below),
                      where column B is expressed as a function of the target
                      z-score ranges (column A). 

                                  ---------------------------- 
                                       A       |        B
                                  ----------------------------
                                    4.0 - 5.0  |       1.9
                                  ----------------------------
                                    3.0 - 4.0  |       1.8
                                  ----------------------------
                                   2.75 - 3.0  |       1.7
                                  ----------------------------
                                   2.50 - 2.75 |       1.6
                                     


                  W = monthly value is duplicated from the previous month,
                      based upon regional and spatial criteria and is only 
                      applied from the year 2000 to the present.                   

                  Quality Controlled Adjusted (QCA) QC Flags:

                  A = alternative method of adjustment used.

		  Q = value removed; original observation flagged as invalid during the automated quality control process.
 
                  M = values with a non-blank quality control flag in the "qcu"
                      dataset are set to missing the adjusted dataset and given
                      an "M" quality control flag.

                  X = pairwise algorithm removed the value because of too many
                      inhomogeneities.


          DSFLAG: data source flag for monthly value, 21 possibilities:

                  C = Monthly Climatic Data of the World (MCDW) QC completed 
                      but value is not yet published

                  D = Calculated monthly value from daily data contained within the
                      Global Historical Climatology Network Daily (GHCND) dataset.

                  G = GHCNM v2 station, that was not a v2 station that had multiple
                      time series (for the same element).

                  J = Colonial Era Archive Data
 
                  K = received by the UK Met Office

                  M = Final (Published) Monthly Climatic Data of the World 
                     (MCDW)

                  N = Netherlands, KNMI (Royal Netherlans Meteorological 
                      Institute)

                  P = CLIMAT (Data transmitted over the GTS, not yet fully 
                      processed for the MCDW)

                  U = USHCN v2

                  W = World Weather Records (WWR), 9th series 1991 through 2000 

                  Z = Datzilla (Manual/Expert Assessment)

             0 to 9 = For any station originating from GHCNM v2 that had
                      multiple time series for the same element, this flag
                      represents the 12th digit in the ID from GHCNM v2.
                      See section 2.2.2 for additional information.

                  , = CLIMAT (Data transmitted in BUFR format)                 

    2.2.2 STATIONS WITH MULTIPLE TIME SERIES

          The GHCNM v2 contained several thousand stations that had multiple 
          time series of monthly mean temperature data.  The 12th digit of
          each data record, indicated the time series number, and thus there
          was a potential maximum of 10 time series (e.g. 0 through 9).  These
          same stations in v3 have undergone a merge process, to reduce
          the station time series to one single series, based upon these 
          original and at most 10 time series.

          A simple algorithm was applied to perform the merge.  The algorithm
          consisted of first finding the length (based upon number of non
          missing observations) for each of the time series and then 
          combining all of the series into one based upon a priority scheme
          that would "write" data to the series for the longest series last.

          Therefore, if station A, had 3 time series of TAVG data, as follows:

          1900 to 1978 (79 years of data) [series 1]
          1950 to 1985 (36 years of data) [series 2]
          1990 to 2007 (18 years of data) [series 3]

          The final series would consist of:
 
          1900 to 1978 [series 1]
          1979 to 1985 [series 2]
          1990 to 2007 [series 3]

          The original series number in GHCNM v2, is retained in the GHCNM v3
          data source flag.  

          One caveat to this merge process, is that in the final GHCNM v3  
          processing there is still a master level construction process 
          performed daily, where the entire dataset is construction according
          to a source order overwrite hiearchy (section 2.3), and it is 
          possible that higher order data sources may be interspersed within 
          the 3 series listed above.

    2.2.3 DATA SOURCE HIERARCHY

        The GHCNM v3 is reprocessed on a daily basis, which means as a
        part of that reprocessing, the dataset is reconstructed from all 
        original sources. The advantage to this process is when source 
        datasets are corrected and/or updated the inclusion into GHCNM v3
        is seemless.  The following sources (more fully described in 
        section 2.2.1) have the following overwrite precedance within the 
        daily reprocessing of GHCNM v3 (e.g. source K overwrites source P) 

        G,0-9,U,P,K,C,M,J,N,W,Z

    2.2.4 BIAS CORRECTIONS ANALYSIS PERIOD

        Bias corrections are only applied from 1801 to the present.
        One station, Lund, Sweden (64502627001) is not included in the bias 
        corrected dataset because the period of record for that station is
        1753 to 1773 and thus it ends prior to 1801.

3. HOW TO CITE

    3.1 GHCNM (version 2):

        Peterson, T.C., and R.S. Vose, 1997: An overview of the Global 
            Historical Climatology Network temperature database. Bulletin of 
            the American Meteorological Society, 78 (12), 2837-2849

    3.2 GHCNM (version 3):

        J. H. Lawrimore, M. J. Menne, B. E. Gleason, C. N. Williams, 
            D. B. Wuertz, R. S. Vose, and J. Rennie (2011), An overview of the
            Global Historical Climatology Network monthly mean temperature data
            set, version 3, J. Geophys. Res., 116, D19121, 
            doi:10.1029/2011JD016187. 

4. FUTURE

   The GHCNM is under constant development, some of the following are goals
   for the next few months:

   1) expand and improve metadata
   2) expand and improve graphical product line
   3) continued quality control improvement
   4) inclusion of new data for existing stations, as it becomes available

5. CONTACT

    5.1 QUESTIONS AND FEEDBACK

        NCDC.GHCNM@noaa.gov

    5.2 OBTAINING ARCHIVED VERSIONS

        At this time, the National Climatic Data Center does not maintain an
        online ftp archive of daily processed GHCNM versions.  The latest
        version always overwrites the previous version and thus represents the
        latest data, quality control, etc.  However, if you need to obtain a
        previous version, please email:

        NCDC.GHCNM@noaa.gov

        with your request and please specify the specific version needed.

