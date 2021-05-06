a1 = Author.create(name: "Leeroy Jenkins")

p1 = Post.create(author_id: a1.id, title: "Web Development for Cats")
p2 = Post.create(author_id: a1.id, title: "Web Development for Dogs")

Profile.create(author_id: a1.id, username: "ljenk", email: "ljenk@aol.com", bio: "a very dated reference")

t1 = Tag.create(name: "Internet")
t2 = Tag.create(name: "Cats")
t3 = Tag.create(name: "Dogs")

PostTag.create(post_id: p1.id, tag_id: t1.id)
PostTag.create(post_id: p1.id, tag_id: t2.id)

PostTag.create(post_id: p2.id, tag_id: t1.id)
PostTag.create(post_id: p2.id, tag_id: t3.id)