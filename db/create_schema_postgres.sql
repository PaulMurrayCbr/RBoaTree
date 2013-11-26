drop table tree CASCADE;
drop table tree_node CASCADE;
drop table tree_link CASCADE;

CREATE TABLE tree
(
  -- ActiveRecord columns
  id serial NOT NULL PRIMARY KEY,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  -- boatree columns
  name character varying(255) not null,
  tree_type char(1) not null constraint tree_type_enum check (tree_type in ('T','W','E'))
)
WITH (
  OIDS=FALSE
);

comment on table tree is 'Tag a specific node as being a top-level root node. ';
comment on column tree.tree_type is 'Trees have type ''T''ree, ''W''orkspace, and the ''E''nd tree';

ALTER TABLE tree OWNER TO "tree-admin";
grant select on tree to public;
grant insert, update, delete on tree to "tree-appuser";

CREATE TABLE tree_node
(
  -- ActiveRecord columns
  id serial NOT NULL PRIMARY KEY,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  -- boatree columns
  name character varying(255),
  tree_id integer references tree not null,
  uri  character varying(255) unique,
  published boolean not null default false
)
WITH (
  OIDS=FALSE
);

alter table tree add column tree_node_id integer references tree_node;
comment on column tree.tree_node_id is 'This should be not null, but it is nullable owing to the sequence involved in creating a new tree and its tree node.';

alter table tree_node add column prev_node_id integer references tree_node;
alter table tree_node add column next_node_id integer references tree_node;

-- create the end node. global across all graphs that make use of this structure and ontology
insert into tree(id, name, tree_type) values (0, '[END]', 'E');
insert into tree_node(id, name, tree_id, uri) values (0, '[END]', 0, 'http://biodiversitry.org.au/boatree/structure#END');
update tree set tree_node_id = 0 where id = 0;

comment on column tree_node.uri is 'Assigned persistent uri. If this column is null, then the node is a draft node.';

ALTER TABLE tree_node OWNER TO "tree-admin";
grant select on tree_node to public;
grant insert, update, delete on tree_node to "tree-appuser";

CREATE TABLE tree_link
(
  -- ActiveRecord columns
  id serial NOT NULL PRIMARY KEY,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  -- boatree columns
  super_node_id integer references tree_node, -- 'super' is a reserved word in many languages
  sub_node_id integer references tree_node,
  link_type char(1) not null constraint link_type_enum check (link_type in ('F','T','V'))
)
WITH (
  OIDS=FALSE
);

comment on column tree_link.link_type is '''T''racking, ''V''ersioning, or ''F''ixed';

ALTER TABLE tree_link OWNER TO "tree-admin";
grant select on tree_link to public;
grant insert, update, delete on tree_link to "tree-appuser";

grant all on all sequences in schema public to "tree-appuser";
