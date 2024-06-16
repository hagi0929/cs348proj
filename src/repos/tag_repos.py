from sqlalchemy.sql import text
from .. import db
from ..model.tag import Tag
from ..model.problem import ProblemDetailed

class TagRepos:
    @staticmethod
    def get_tag_list() -> list[Tag]:
        query = text("""
        SELECT tag_id, type, content FROM Tag
        """)
        result = db.session.execute(query)
        tags = []
        for row in result:
            tags.append(Tag(
                tag_id=row[0],
                type=row[1],
                content=row[2],
            ))
        return tags

    @staticmethod
    def get_tag_by_id(tag_id: int) -> Tag:
        query = text("""
        SELECT tag_id, type, content FROM Tag
        WHERE tag_id = :tid
        """)
        parameters = {'tid': tag_id}
        result = db.session.execute(query, parameters)
        row = result.fetchone()
        if row:
            return Tag(
                tag_id=row[0],
                type=row[1],
                content=row[2],
            )
        return None

    @staticmethod
    def create_tag(tag: Tag) -> int:
        query = text("""
            INSERT INTO Tag (type, content)
            VALUES (:type, :content)
            RETURNING tag_id
        """)
        result = db.session.execute(query, {
            'type': tag.type,
            'content': tag.content,
        })
        tag_id = result.fetchone()[0]

        db.session.commit()
        return tag_id

    @staticmethod
    def delete_tag(tag_id: int) -> bool:
        query = text("""
            DELETE FROM Tag
            WHERE tag_id = :tid
        """)
        result = db.session.execute(query, {'tid': tag_id})
        db.session.commit()
        return result.rowcount > 0
    
    @staticmethod
    def find_problems_by_tag(tag_type: str, tag_content: str) -> list[ProblemDetailed]:
        query = text("""
        SELECT P.problem_id, P.title, P.description, P.difficulty, P.created_by, P.created_at
        FROM Problem P
        JOIN ProblemTag PT ON P.problem_id = PT.problem_id
        JOIN Tag T ON PT.tag_id = T.tag_id
        WHERE T.type = :tag_type AND T.content = :tag_content
        """)
        result = db.session.execute(query, {'tag_type': tag_type, 'tag_content': tag_content})
        problems = [ProblemDetailed(row[0], row[1], row[2], row[3], row[4], row[5]) for row in result]
        return problems

    @staticmethod
    def list_all_problems_with_tags() -> list[dict]:
        query = text("""
        SELECT P.problem_id, P.title, T.type, T.content
        FROM Problem P
        JOIN ProblemTag PT ON P.problem_id = PT.problem_id
        JOIN Tag T ON PT.tag_id = T.tag_id
        ORDER BY P.problem_id, T.type
        """)
        result = db.session.execute(query)
        problems_with_tags = []
        for row in result:
            problems_with_tags.append({
                'problem_id': row[0],
                'title': row[1],
                'type': row[2],
                'content': row[3]
            })
        return problems_with_tags
