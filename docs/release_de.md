# goss Releasen

Letzte Version in Github unter Releases checken
* Ggf. Draft-Releases beachten
* Neue NEWVERSION anhand von [semantic versioning](https://semver.org/) ausdenken
* `git checkout develop && git pull`
* `git flow release start NEWVERSION`
   * NEWVERSION ist bspw. v1.15.1
   * ggf. wird noch ein `git flow init` nötig
      * 'production releases' auf master setzen
         * `Branch name for production releases: [] master`
      * default-Werte bei allen anderen Angaben akzeptieren
* VERSION=NEWVERSION in Makefile setzen
* `git add Makefile`
* `git commit -m "Bump version"`
* `CHANGELOG.md` pflegen (nach [keepachangelog.com](https://keepachangelog.com/en/1.0.0/))
* `git add CHANGELOG.md && git commit -m "Update changelog"`
* `git flow release finish -s NEWVERSION`
* `git checkout NEWVERSION`
* `make clean && make`
* export APT_API_USERNAME="USERNAME" (aus dem Password Manager: `aptly`)
* export APT_API_PASSWORD="PASSWORD" (aus dem Password Manager: `aptly`)
* export APT_API_SIGNPHRASE="SIGNPHRASE" (aus dem Password Manager: `signphrase`)
* `make deploy`
* `git push origin master`
* `git push origin develop --tags`
* Release in Github bearbeiten
   - Die Release-Seite in dem Github-Projekt öffnen und den neuen Eintrag editieren (Version des neuen Eintrages anklicken).
   - Version in das Titelfeld kopieren
   - Grund für das Release eintragen (kann direkt aus Changelog übernommen werden)
   - Zusätzlich die von `make` generierten Keys `*.sha256sum` und `*.asc` hochladen