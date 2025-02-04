from flask import jsonify, request
from ..service.discussion_service import DiscussionService
from ..model.discussion import DiscussionCreationRequest
from flask_smorest import Blueprint

discussion_bp = Blueprint("discussions", __name__)

@discussion_bp.route('/<int:problem_id>', methods=['POST'])

def create_discussion(problem_id):
    data = request.get_json()
    try:
        discussion_request = DiscussionCreationRequest(
            problem_id=problem_id,
            parentdiscussion_id=data['parentdiscussion_id'],
            user_id=data['user_id'],
            title=data['title'],
            content=data['content']
        )
        print(discussion_request.problem_id, discussion_request.user_id, discussion_request.content)
        discussion_id = DiscussionService.create_discussion(discussion_request)
        response = {
            'discussion_id': discussion_id,
            'problem_id': discussion_request.problem_id,
            'parentdiscussion_id': discussion_request.parentdiscussion_id,
            'user_id': discussion_request.user_id,
            'title': discussion_request.title,
            'content': discussion_request.content
        }
        return jsonify(response), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400


@discussion_bp.route('/problem/<int:problem_id>', methods=['GET'])
def get_discussion_list(problem_id):
    discussions = [vars(d) for d in DiscussionService.get_discussion_list_by_problem(problem_id)]
    return jsonify(discussions)


@discussion_bp.route('/discussion/<int:discussion_id>', methods=['GET'])
def get_discussion(discussion_id):
    discussion = DiscussionService.get_discussion_by_id(discussion_id)
    if discussion:
        return jsonify(discussion.to_dict())
    return jsonify({'message': 'Discussion not found'}), 404

@discussion_bp.route('/thread/<int:parentdiscussion_id>', methods=['GET'])
def get_discussion_thread_list(parentdiscussion_id):
    print("hello")
    discussions = [vars(d) for d in DiscussionService.get_discussions_by_parent_id(parentdiscussion_id)]
    return jsonify(discussions)

@discussion_bp.route('/<int:discussion_id>', methods=['PUT'])
def update_discussion(discussion_id):
    data = request.get_json()
    try:
        content = data['content']
        DiscussionService.update_discussion(discussion_id, content)
        return jsonify({'message': 'Discussion updated successfully'})
    except ValueError as e:
        return jsonify({'error': str(e)}), 400


@discussion_bp.route('/<int:discussion_id>', methods=['DELETE'])
def delete_discussion(discussion_id):
    try:
        print(discussion_id)
        DiscussionService.delete_discussion(discussion_id)
        return jsonify({'message': 'Discussion deleted successfully'})
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
