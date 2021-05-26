author1 = Author.create(name: "Leeroy Jenkins")
author2 = Author.create(name: Faker::Name.unique.name)
author3 = Author.create(name: Faker::Name.unique.name)

Profile.create(author_id: author1.id, username: "ljenk", email: "ljenk@aol.com", bio: "a very dated reference")

post1 = Post.create(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph, author_id: author1.id)
post2 = Post.create(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph, author_id: author2.id)
post3 = Post.create(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph, author_id: author3.id)
post4 = Post.create(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph, author_id: author3.id)

tag1 = Tag.create(name: Faker::Lorem.word)
tag2 = Tag.create(name: Faker::Lorem.word)
tag3 = Tag.create(name: Faker::Lorem.word)

PostTag.create(post_id: post1.id, tag_id: tag1.id)
PostTag.create(post_id: post1.id, tag_id: tag2.id)

PostTag.create(post_id: post2.id, tag_id: tag1.id)
PostTag.create(post_id: post2.id, tag_id: tag3.id)

PostTag.create(post_id: post3.id, tag_id: tag2.id)

PostTag.create(post_id: post4.id, tag_id: tag2.id)
PostTag.create(post_id: post4.id, tag_id: tag3.id)
