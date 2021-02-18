(import simpletemplate)
(import dbtools)
(import dbtools.datemapper)

(setv dbtools.DEBUG True)

(setv platform "myriad")
(setv refcat ["Law" "Communication, Cultural and Media Studies, Library and Information Management" "Modern Languages and Linguistics" "Philosophy" "Politics and International Studies"])
(setv nmonths 60)
(setv current (dbtools.datemapper.fromisoformat "2021-01-01"))
(setv monthlist (dbtools.datemapper.getlastnmonths current nmonths))
(setv seperator " | ")
(dbtools.log (str monthlist) "Months")

(setv reflist (dbtools.sqllist refcat))

(setv keys {"%DB%" (+ platform "_sgelogs") "%PERIOD%" "2021-01" "%REFCAT%" reflist})
(setv query (simpletemplate.templatefile
                           :filename "sql/cputime-for-refs.sql"
                           :keys keys))



(setv data (dbtools.dbquery :db (get keys "%DB%")
                           :query query))

(print ">>> DEBUG Raw Data:")
(print data)
(print "")

(print ">>> CSV:")
(print "Ref Category" seperator :end "")
(for [a refcat]
     (print a :end seperator)
)
(print "")
(print "Period" seperator "Usage (h)")
(for [i (range nmonths)]
     (setv index (+ i 1))
     (setv pperiod (dbtools.datemapper.datetoperiod (get monthlist index)))
     (print pperiod :end seperator)
     (for [a refcat]
          (setv value 0.0)
          (for [b data]
               (if (and (= (get b "Period") pperiod) (= (get b "ref_category") a)) (setv value(get b "Total CPU Time Usage")))
          )
          (print value :end seperator)
     )
     (print "")

)
