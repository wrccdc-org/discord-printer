FROM ubuntu:22.04 AS builder
WORKDIR /tmp
RUN apt-get update \
    && apt-get -y install cups printer-driver-cups-pdf cups-ipp-utils git sed busybox-syslogd \
 #   && apt-get -y upgrade \
    && /etc/init.d/cups start \
    && lpadmin -p pdfprint -v cups-pdf:/ -E -i /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd -u allow:all \
    && cupsctl --remote-admin --remote-any --share-printers --user-cancel-any \
    && sed -i 's/Listen localhost:631/Port 631\nListen 0.0.0.0:631/' /etc/cups/cupsd.conf \
    && /etc/init.d/cups stop \
    && cd /tmp ; git clone https://github.com/fieu/discord.sh.git \
    && cp ./discord.sh/discord.sh /opt/ \
    && cd /opt ; rm -rf /tmp/discord.sh \
    && apt-get remove -y git \
    && mkdir -p /var/spool/pdf \
    && chmod -Rv 077 /var/spool/pdf
WORKDIR /opt
COPY cups-pdf.conf /etc/cups/cups-pdf.conf
COPY cups-browsed.conf /etc/cups/cups-browsed.conf
COPY printer.sh /opt/printer.sh
COPY launch-docker.sh /opt/launch-docker.sh
COPY logo.png /opt/
RUN chmod +x /opt/*.sh; chmod -Rv 777 /opt/logo.png
EXPOSE 631
EXPOSE 8080
EXPOSE 1631
USER root
CMD /opt/launch-docker.sh
