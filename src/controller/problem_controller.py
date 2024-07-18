from flask import jsonify, request
from flask_smorest import Blueprint
from src.middleware.middleware import require_auth
from src.model.problem import ProblemCreationRequest
from src.service.problem_service import ProblemService

problem_bp = Blueprint("problems", __name__)


@problem_bp.route('/', methods=['POST'])
def create_problem():
    data = request.get_json()
    try:
        problem_request = ProblemCreationRequest(
            title=data['title'],
            description=data['description'],
            created_by=data['created_by'],
            tags=data.get('tags', []),
            test_cases=data.get('test_cases', [])
        )
        problem_id = ProblemService.create_problem(problem_request)
        response = {
            'problem_id': problem_id,
            'title': problem_request.title,
            'description': problem_request.description,
            'created_by': problem_request.created_by,
            'tags': problem_request.tags,
            'test_cases': problem_request.test_cases
        }
        return jsonify(response), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400


@problem_bp.route('/list', methods=['GET'])
def get_problem_list():
    problems = [vars(p) for p in ProblemService.get_problem_list()]
    return jsonify(problems)


@problem_bp.route('/<int:problem_id>', methods=['GET'])
@require_auth([])
def get_problem(problem_id):
    problem = ProblemService.get_problem_by_id(problem_id)
    if problem:
        return jsonify(problem.to_dict())
    return jsonify({'message': 'Problem not found'}), 404


@problem_bp.route('/<int:problem_id>', methods=['DELETE'])
@require_auth([], pass_auth_info=True)
def delete_problem(problem_id, **kwargs):
    auth_info = kwargs['auth_data']
    user_id = auth_info.get('user_id', None)
    list_of_permissions = auth_info.get('permissions', [])
    problem = ProblemService.get_problem_by_id(problem_id)
    if problem is None:
        raise Exception("problem does not exist")
    if "delete_all_problem" in list_of_permissions or ("delete_own_problem" in list_of_permissions and user_id == problem.problem_id):
        ProblemService.delete_problem(problem_id)
    if problem:
        return jsonify(problem.to_dict())
    return jsonify({'message': 'Problem not found'}), 404
