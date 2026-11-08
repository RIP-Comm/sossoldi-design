// A person of the team (Settings > Info > Collaborators). The role is a job
// title and stays in English in every language, like the names. The link is
// empty until the real one is known: the row then does nothing.

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/widgets.dart';

enum CollaboratorLinkType {
  github(PhosphorIconsRegular.githubLogo),
  website(PhosphorIconsRegular.globe),
  linkedin(PhosphorIconsRegular.linkedinLogo);

  const CollaboratorLinkType(this.icon);
  final IconData icon;
}

class Collaborator {
  const Collaborator(this.name, this.role, this.type, {this.url = ''});

  final String name;
  final String role;
  final CollaboratorLinkType type;
  final String url;
}

const collaborators = <Collaborator>[
  Collaborator(
    'Marco Perugini',
    'Project Manager',
    CollaboratorLinkType.github,
  ),
  Collaborator(
    'Michele Vulcano',
    'Maintainer, Backend Dev',
    CollaboratorLinkType.github,
  ),
  Collaborator('Luca Antonelli', 'Maintainer', CollaboratorLinkType.github),
  Collaborator(
    'Federico Pozzato',
    'UX/UI Designer',
    CollaboratorLinkType.website,
  ),
  Collaborator('GBergatto', 'Full Stack Dev', CollaboratorLinkType.github),
  Collaborator('0xBaggi', 'Frontend Dev', CollaboratorLinkType.github),
  Collaborator(
    'Alessandro Mariani',
    'Full Stack Dev',
    CollaboratorLinkType.github,
  ),
  Collaborator('filippoml', 'Full Stack Dev', CollaboratorLinkType.github),
  Collaborator('sainzrow', 'Backend Dev', CollaboratorLinkType.github),
  Collaborator(
    'Alessandro Guerra',
    'Full Stack Dev',
    CollaboratorLinkType.github,
  ),
  Collaborator('napitek', 'Full Stack Dev', CollaboratorLinkType.github),
  Collaborator(
    'Alessandro Bongiovanni',
    'Flutter Dev',
    CollaboratorLinkType.github,
  ),
  Collaborator(
    'Emanuel Passaro',
    'Social Media Manager',
    CollaboratorLinkType.linkedin,
  ),
  Collaborator(
    'Carolina Verdiani',
    'Marketing Project Manager',
    CollaboratorLinkType.linkedin,
  ),
  Collaborator(
    'Alessia Schina',
    'UX/UI Designer',
    CollaboratorLinkType.linkedin,
  ),
  Collaborator(
    'Federico Bruzzone',
    'Former Maintainer',
    CollaboratorLinkType.github,
  ),
];
