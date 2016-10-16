INSERT INTO `ls_user` VALUES
  (1,'Celestia','sha512:1000:BnADF5whLiT66QpyCWzXM/ygiqr7rbMS:4f4BMmgBzpw2zubDWQVlvPyEgScPIixd','celestia@canterlot.eq',1000.000,'2016-10-15 13:42:35','2016-10-15 13:43:53',NULL,'127.0.0.1',1000.000,0,1,'461eada4ddda8b3a1c8c032629f9b6fa',NULL,'other',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,0,0,NULL,1),
  (2,'Luna','sha512:1000:BhcoYykEDo/6u+NQsBMPyljUhMNpjCkn:NbpHkqDhK8tXC0nc9F/5BcIQEJGNTich','luna@canterlot.eq',1000.000,'2016-10-15 13:45:26','2016-10-15 13:46:19',NULL,'127.0.0.1',1000.000,0,1,'f25d7af4ffe3d90f92cfb93a506cee8d',NULL,'other',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,0,0,NULL,1),
  (3,'Sparkle','sha512:1000:KnJpqJHzUFgehBDd0Ky7/2eSnWZ0r0tK:+AdrKiqgTHKilYW91QJdXKzSn7NXGLFs','twilight@ponyville.eq',1000.000,'2016-10-15 13:57:21','2016-10-15 13:58:31','2016-10-15 13:58:54','127.0.0.1',1000.000,0,1,'3516d317a63ead888a2fd835d26c562e',NULL,'other',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,0,0,NULL,1),
  (4,'Spitfire','sha512:1000:L5sLG8Pb+4uVVkFFBIbauosvo79riDq2:ZCQ2+iENdun97SHqY89kEOdY17KamJR0','spitfire@cloudsdale.eq',1000.000,'2016-10-15 14:02:07','2016-10-15 14:03:22','2016-10-15 14:06:03','127.0.0.1',1000.000,0,1,'beef61a3d1382aad6bafd43b54ac07cc',NULL,'other',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,0,0,NULL,1);

INSERT INTO `ls_user_administrator` VALUES (1);

INSERT INTO `ls_blog` VALUES
  (1,1,'Блог им. Celestia','Это ваш персональный блог.','personal','2016-10-15 13:42:36',NULL,0.000,0,0,0,-1000.000,NULL,NULL),
  (2,2,'Блог им. Luna','Это ваш персональный блог.','personal','2016-10-15 13:45:26',NULL,0.000,0,0,0,-1000.000,NULL,NULL),
  (3,2,'The Astronomical Astronomer\'s Almanac to All Things Astronomy','The Astronomical Astronomer\'s Almanac to All Things Astronomy','open','2016-10-15 13:51:19',NULL,0.000,0,0,1,0.000,'astronomy',NULL),
  (4,3,'Блог им. Sparkle','Это ваш персональный блог.','personal','2016-10-15 13:57:21',NULL,0.000,0,0,1,-1000.000,NULL,NULL),(5,4,'Блог им. Spitfire','Это ваш персональный блог.','personal','2016-10-15 14:02:07',NULL,0.000,0,0,0,-1000.000,NULL,NULL),
  (6,4,'Wonderbolts','Wonderbolts privete blog','close','2016-10-15 14:05:24',NULL,0.000,0,0,1,0.000,'wonderbolts',NULL);


INSERT INTO `ls_topic` VALUES
  (1,3,2,'topic','Observation of Gravitational Waves from a Binary Black Hole Merger','LIGO,black hole','2016-10-15 13:54:23',NULL,'127.0.0.1',1,1,1,0.000,0,0,0,0,0,1,0,'Read next →',0,'240b10b22cdd74df5f331ac4c4d6ab81'),
  (2,4,3,'topic','Library of Alexandria','library,scrolls','2016-10-15 14:01:05',NULL,'127.0.0.1',1,1,0,0.000,0,0,0,0,0,0,0,NULL,0,'dc17af6fafcd5009ffc55f4c50275443'),
  (3,6,4,'topic','Chat #1','wonderbolts,chat','2016-10-15 14:05:53',NULL,'127.0.0.1',1,1,0,0.000,0,0,0,0,0,1,0,NULL,0,'a347f40acf9ed61e9016e41efaa75978');


INSERT INTO `ls_topic_content` VALUES
  (1,'On September 14, 2015 at 09:50:45 UTC the two detectors of the Laser Interferometer Gravitational-Wave Observatory simultaneously observed a transient gravitational-wave signal. The signal sweeps upwards in frequency from 35 to 250 Hz with a peak gravitational-wave strain of 1.0×10−21. <br/>\r\n<a id=\"cut\"></a> <br/>\r\nIt matches the waveform predicted by general relativity for the inspiral and merger of a pair of black holes and the ringdown of the resulting single black hole. The signal was observed with a matched-filter signal-to-noise ratio of 24 and a false alarm rate estimated to be less than 1 event per 203 000 years, equivalent to a significance greater than 5.1σ. <br/>\r\n<br/>\r\nThe source lies at a luminosity distance of 410−180+160  Mpc corresponding to a redshift z=0.09−0.04+0.03. In the source frame, the initial black hole masses are 36−4+5M⊙ and 29−4+4M⊙, and the final black hole mass is 62−4+4M⊙, with 3.0−0.5+0.5M⊙c2 radiated in gravitational waves. <br/>\r\n<br/>\r\nAll uncertainties define 90% credible intervals. These observations demonstrate the existence of binary stellar-mass black hole systems. This is the first direct detection of gravitational waves and the first observation of a binary black hole merger.','On September 14, 2015 at 09:50:45 UTC the two detectors of the Laser Interferometer Gravitational-Wave Observatory simultaneously observed a transient gravitational-wave signal. The signal sweeps upwards in frequency from 35 to 250 Hz with a peak gravitational-wave strain of 1.0×10−21. <br/>\r\n','On September 14, 2015 at 09:50:45 UTC the two detectors of the Laser Interferometer Gravitational-Wave Observatory simultaneously observed a transient gravitational-wave signal. The signal sweeps upwards in frequency from 35 to 250 Hz with a peak gravitational-wave strain of 1.0×10−21. \r\n<cut name=\"Read next →\">\r\nIt matches the waveform predicted by general relativity for the inspiral and merger of a pair of black holes and the ringdown of the resulting single black hole. The signal was observed with a matched-filter signal-to-noise ratio of 24 and a false alarm rate estimated to be less than 1 event per 203 000 years, equivalent to a significance greater than 5.1σ. \r\n\r\nThe source lies at a luminosity distance of 410−180+160  Mpc corresponding to a redshift z=0.09−0.04+0.03. In the source frame, the initial black hole masses are 36−4+5M⊙ and 29−4+4M⊙, and the final black hole mass is 62−4+4M⊙, with 3.0−0.5+0.5M⊙c2 radiated in gravitational waves. \r\n\r\nAll uncertainties define 90% credible intervals. These observations demonstrate the existence of binary stellar-mass black hole systems. This is the first direct detection of gravitational waves and the first observation of a binary black hole merger.','s:0:\"\";'),
  (2,'The Royal Library of Alexandria or Ancient Library of Alexandria in Alexandria, Egypt, was one of the largest and most significant libraries of the ancient world. It was dedicated to the Muses, the nine goddesses of the arts. It flourished under the patronage of the Ptolemaic dynasty and functioned as a major center of scholarship from its construction in the 3rd century BC until the Roman conquest of Egypt in 30 BC, with collections of works, lecture halls, meeting rooms, and gardens. The library was part of a larger research institution called the Musaeum of Alexandria, where many of the most famous thinkers of the ancient world studied.<br/>\r\n<br/>\r\nThe library was created by Ptolemy I Soter, who was a Macedonian general and the successor of Alexander the Great. Most of the books were kept as papyrus scrolls. It is unknown precisely how many such scrolls were housed at any given time, but estimates range from 40,000 to 400,000 at its height.<br/>\r\n<br/>\r\nArguably, this library is most famous for having been burned down resulting in the loss of many scrolls and books; its destruction has become a symbol for the loss of cultural knowledge. Sources differ on who was responsible for its destruction and when it occurred. The library may in truth have suffered several fires over many years. Possible occasions for the partial or complete destruction of the Library of Alexandria include a fire set by the army of Julius Caesar in 48 BC and an attack by Aurelian in the 270s AD.<br/>\r\n<br/>\r\nAfter the main library was destroyed, scholars used a «daughter library» in a temple known as the Serapeum, located in another part of the city. According to Socrates of Constantinople, Coptic Pope Theophilus destroyed the Serapeum in AD 391, although it is not certain what it contained or if it contained any significant fraction of the documents that were in the main library. The library may have finally been destroyed during the Muslim conquest of Egypt in (or after) AD 642.','The Royal Library of Alexandria or Ancient Library of Alexandria in Alexandria, Egypt, was one of the largest and most significant libraries of the ancient world. It was dedicated to the Muses, the nine goddesses of the arts. It flourished under the patronage of the Ptolemaic dynasty and functioned as a major center of scholarship from its construction in the 3rd century BC until the Roman conquest of Egypt in 30 BC, with collections of works, lecture halls, meeting rooms, and gardens. The library was part of a larger research institution called the Musaeum of Alexandria, where many of the most famous thinkers of the ancient world studied.<br/>\r\n<br/>\r\nThe library was created by Ptolemy I Soter, who was a Macedonian general and the successor of Alexander the Great. Most of the books were kept as papyrus scrolls. It is unknown precisely how many such scrolls were housed at any given time, but estimates range from 40,000 to 400,000 at its height.<br/>\r\n<br/>\r\nArguably, this library is most famous for having been burned down resulting in the loss of many scrolls and books; its destruction has become a symbol for the loss of cultural knowledge. Sources differ on who was responsible for its destruction and when it occurred. The library may in truth have suffered several fires over many years. Possible occasions for the partial or complete destruction of the Library of Alexandria include a fire set by the army of Julius Caesar in 48 BC and an attack by Aurelian in the 270s AD.<br/>\r\n<br/>\r\nAfter the main library was destroyed, scholars used a «daughter library» in a temple known as the Serapeum, located in another part of the city. According to Socrates of Constantinople, Coptic Pope Theophilus destroyed the Serapeum in AD 391, although it is not certain what it contained or if it contained any significant fraction of the documents that were in the main library. The library may have finally been destroyed during the Muslim conquest of Egypt in (or after) AD 642.','The Royal Library of Alexandria or Ancient Library of Alexandria in Alexandria, Egypt, was one of the largest and most significant libraries of the ancient world. It was dedicated to the Muses, the nine goddesses of the arts. It flourished under the patronage of the Ptolemaic dynasty and functioned as a major center of scholarship from its construction in the 3rd century BC until the Roman conquest of Egypt in 30 BC, with collections of works, lecture halls, meeting rooms, and gardens. The library was part of a larger research institution called the Musaeum of Alexandria, where many of the most famous thinkers of the ancient world studied.\r\n\r\nThe library was created by Ptolemy I Soter, who was a Macedonian general and the successor of Alexander the Great. Most of the books were kept as papyrus scrolls. It is unknown precisely how many such scrolls were housed at any given time, but estimates range from 40,000 to 400,000 at its height.\r\n\r\nArguably, this library is most famous for having been burned down resulting in the loss of many scrolls and books; its destruction has become a symbol for the loss of cultural knowledge. Sources differ on who was responsible for its destruction and when it occurred. The library may in truth have suffered several fires over many years. Possible occasions for the partial or complete destruction of the Library of Alexandria include a fire set by the army of Julius Caesar in 48 BC and an attack by Aurelian in the 270s AD.\r\n\r\nAfter the main library was destroyed, scholars used a \"daughter library\" in a temple known as the Serapeum, located in another part of the city. According to Socrates of Constantinople, Coptic Pope Theophilus destroyed the Serapeum in AD 391, although it is not certain what it contained or if it contained any significant fraction of the documents that were in the main library. The library may have finally been destroyed during the Muslim conquest of Egypt in (or after) AD 642.','s:0:\"\";'),
  (3,'Here be our private chat','Here be our private chat','Here be our private chat','s:0:\"\";');

INSERT INTO `ls_topic_read` VALUES
  (1,2,'2016-10-15 13:54:46',0,0),
  (1,3,'2016-10-15 13:58:55',1,1),
  (2,3,'2016-10-15 14:01:06',0,0),
  (3,4,'2016-10-15 14:06:04',1,2);

INSERT INTO `ls_topic_tag` VALUES
  (1,1,2,3,'LIGO'),
  (2,1,2,3,'black hole'),
  (3,2,3,4,'library'),
  (4,2,3,4,'scrolls'),
  (5,3,4,6,'wonderbolts'),
  (6,3,4,6,'chat');

INSERT INTO `ls_comment` VALUES 
  (1,NULL,0,0,0,1,'topic',3,3,'Great!',NULL,'73bc3b5a9a2873d81d33899f1fd68439','2016-10-15 13:58:54',NULL,NULL,'127.0.0.1',0.000,0,0,0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL),
  (2,NULL,0,0,0,3,'topic',6,4,'To the stream!',NULL,'cacc0ac95f4892e6b9f5325478ae795c','2016-10-15 14:06:03',NULL,NULL,'127.0.0.1',0.000,0,0,0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL);


INSERT INTO `ls_comment_online` VALUES 
  (1,1,'topic',3,1),
  (2,3,'topic',6,2);

INSERT INTO `ls_stream_event` VALUES 
  (1,'add_blog',3,2,'2016-10-15 13:51:19',1),
  (2,'add_topic',1,2,'2016-10-15 13:54:24',1),
  (3,'add_comment',1,3,'2016-10-15 13:58:54',1),
  (4,'add_topic',2,3,'2016-10-15 14:01:05',1),
  (5,'add_blog',6,4,'2016-10-15 14:05:24',1);


INSERT INTO `ls_stream_user_type` VALUES 
  (1,'add_blog'),
  (1,'add_comment'),
  (1,'add_friend'),
  (1,'add_topic'),
  (1,'vote_topic'),
  (2,'add_blog'),
  (2,'add_comment'),
  (2,'add_friend'),
  (2,'add_topic'),
  (2,'vote_topic'),
  (3,'add_blog'),
  (3,'add_comment'),
  (3,'add_friend'),
  (3,'add_topic'),
  (3,'vote_topic'),
  (4,'add_blog'),
  (4,'add_comment'),
  (4,'add_friend'),
  (4,'add_topic'),
  (4,'vote_topic');

INSERT INTO `ls_subscribe` VALUES 
  (1,'topic_new_comment',1,'luna@canterlot.eq','2016-10-15 13:54:24',NULL,'127.0.0.1','bd49c6d6771c807b219499408d23f6c0',0),
  (2,'topic_new_comment',2,'twilight@ponyville.eq','2016-10-15 14:01:05',NULL,'127.0.0.1','66787fd07d7890ea62ed8e7455ad83c7',0),
  (3,'topic_new_comment',3,'spitfire@cloudsdale.eq','2016-10-15 14:05:53',NULL,'127.0.0.1','af888a0f30fab178e95219de31b0c585',0);
