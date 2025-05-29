from flask import Flask, request, render_template
from datetime import datetime, timedelta
import pymysql
import os

app = Flask(__name__)

# Forces Flask to reload HTML templates (like form.html) when changed, without restarting the app (for development)
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Accept both /submit and /submit/ as the same route
app.url_map.strict_slashes = False

# Environment variables
db_host = os.environ.get("DB_HOST")
db_user = os.environ.get("DB_USER")
db_password = os.environ.get("DB_PASS")
db_name = os.environ.get("DB_NAME")


@app.route('/')
def form():
    return render_template('enter_result_form.html')

@app.route('/submit-result', methods=['POST'])
def submit_result():
    draw_id = int(request.form.get('draw_id'))
    player1 = int(request.form.get('player1'))
    player2 = int(request.form.get('player2'))
    set1_p1 = int(request.form.get('set1_p1'))
    set1_p2 = int(request.form.get('set1_p2'))
    tiebreak1_p1 = int(request.form.get('tiebreak1_p1'))
    tiebreak1_p2 = int(request.form.get('tiebreak1_p2'))
    set2_p1 = int(request.form.get('set2_p1'))
    set2_p2 = int(request.form.get('set2_p2'))
    tiebreak2_p1 = int(request.form.get('tiebreak2_p1'))
    tiebreak2_p2 = int(request.form.get('tiebreak2_p2'))
    super_p1 = int(request.form.get('super_p1'))
    super_p2 = int(request.form.get('super_p2'))
    winner = int(request.form.get('winner'))
    status1 = int(request.form.get('status1'))
    status2 = int(request.form.get('status2'))
    match_date = request.form.get('match_date')

    conn = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name, port=3306)
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO Matches (
            draw_id, player1_id, player2_id, winner_id,
            player1_status_id, player2_status_id,
            set1_player1, set1_player2,
            set1_player1_tiebreak, set1_player2_tiebreak,
            set2_player1, set2_player2,
            set2_player1_tiebreak, set2_player2_tiebreak,
            supertiebreak_player1, supertiebreak_player2,
            match_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        (
            draw_id, player1, player2, player1 if winner == 1 else player2,
            status1, status2,
            set1_p1, set1_p2, tiebreak1_p1, tiebreak1_p2,
            set2_p1, set2_p2, tiebreak2_p1, tiebreak2_p2,
            super_p1, super_p2,
            match_date
        )
    )

    conn.commit()
    cursor.close()
    conn.close()

    return render_template('confirm.html', winner=player1 if winner == 1 else player2)

@app.route('/past-draws/<week>')
def past_draws(week):
    monday = datetime.strptime(week + '-1', "%Y-W%W-%w")
    sunday = monday + timedelta(days=6)

    conn = pymysql.connect(
        host=db_host,
        user=db_user,
        password=db_password,
        database=db_name,
        cursorclass=pymysql.cursors.DictCursor
    )
    cursor = conn.cursor()

    cursor.execute("""
        SELECT t.tournament_id, t.name, t.start_date, tc.description AS category_description,
               d.draw_id
        FROM Draws d
        JOIN Tournaments t ON t.tournament_id = d.tournament_id
        JOIN TournamentCategory tc ON t.category_id = tc.category_id
        WHERE t.start_date BETWEEN %s AND %s
        ORDER BY t.tournament_id, d.draw_id
    """, (monday.date(), sunday.date()))
    draws = cursor.fetchall()

    draw_data = {}

    for draw in draws:
        draw_id = draw['draw_id']

        cursor.execute("""
            SELECT m.*,
                       CONCAT(p1.first_name, ' ', p1.last_name) AS player1_name,
                       CONCAT(p2.first_name, ' ', p2.last_name) AS player2_name,
                       ps1.status_description AS status1_desc,
                       ps2.status_description AS status2_desc,
                       mr.code AS round_code
                FROM Matches m
                LEFT JOIN Players p1 ON m.player1_id = p1.player_id
                LEFT JOIN Players p2 ON m.player2_id = p2.player_id
                LEFT JOIN PlayerStatus ps1 ON m.player1_status_id = ps1.status_id
                LEFT JOIN PlayerStatus ps2 ON m.player2_status_id = ps2.status_id
                LEFT JOIN MatchRound mr ON m.round_id = mr.round_id
                WHERE m.draw_id = %s
                ORDER BY m.round_id, m.match_id        """, (draw_id,))
        matches = cursor.fetchall()

        for match in matches:
            p1_sets = []
            p2_sets = []
            for set_num in [1, 2]:
                p1 = match.get(f"set{set_num}_player1")
                p2 = match.get(f"set{set_num}_player2")
                if p1 is not None and p2 is not None:
                    p1_sets.append(str(p1))
                    p2_sets.append(str(p2))
            if match.get("supertiebreak_player1") is not None:
                p1_sets.append(str(match["supertiebreak_player1"]))
                p2_sets.append(str(match["supertiebreak_player2"]))
            match["sets_p1"] = " ".join(p1_sets)
            match["sets_p2"] = " ".join(p2_sets)

        round_groups = {}
        for match in matches:
            rc = match["round_code"]
            round_groups.setdefault(rc, []).append(match)

        draw_data[draw_id] = {
            "info": draw,
            "rounds": round_groups
        }

    cursor.close()
    conn.close()

    return render_template("admin_draw.html", draw_data=draw_data, monday=monday, sunday=sunday, week=week)


@app.route("/tournaments")
def tournament_list():
    conn = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name,
                           cursorclass=pymysql.cursors.DictCursor)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.tournament_id, t.name, DATE_FORMAT(t.start_date, '%%d/%%m/%%Y') as start_date,
               DATE_FORMAT(t.end_date, '%%d/%%m/%%Y') as end_date,
               c.description AS host_nation,
               l.city,
               tc.description AS category
        FROM Tournaments t
        JOIN Location l ON t.location_id = l.location_id
        JOIN Country c ON l.country_id = c.country_id
        JOIN TournamentCategory tc ON t.category_id = tc.category_id
        ORDER BY t.start_date DESC
    """)
    tournaments = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("tournament_list.html", tournaments=tournaments)


@app.route("/draw/<int:tournament_id>")
def public_draw_view(tournament_id):
    conn = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name,
                           cursorclass=pymysql.cursors.DictCursor)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT t.name, DATE_FORMAT(t.start_date, '%%d/%%m/%%Y') as start_date,
               DATE_FORMAT(t.end_date, '%%d/%%m/%%Y') as end_date
        FROM Tournaments t
        WHERE t.tournament_id = %s
    """, (tournament_id,))
    tournament = cursor.fetchone()

    cursor.execute("""
        SELECT 
            d.draw_id, 
            d.gender AS gender_id, 
            ac.code AS age_code, 
            tc.description AS category_description
        FROM Draws d
        JOIN AgeCategory ac ON d.age_category = ac.age_category_id
        JOIN Tournaments t ON d.tournament_id = t.tournament_id
        JOIN TournamentCategory tc ON t.category_id = tc.category_id        
        WHERE d.tournament_id = %s
    """, (tournament_id,))
    draws = cursor.fetchall()

    # Add display values for gender and age
    for draw in draws:
        draw["gender_display"] = "MEN’S" if draw["gender_id"] == 1 else "LADIES’"
        draw["age_display"] = f"{draw['age_code']}+"

    cursor.close()
    conn.close()
    return render_template("public_draw_view.html", tournament=tournament, draws=draws)


@app.route('/health')
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
